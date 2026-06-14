---@class Conform
local M = {}

local utils = require("utils")
local diff = require("utils.conform.diff")

local api = vim.api
local bo = vim.bo
local fn = vim.fn
local uv = vim.uv
local fs = vim.fs

local DEBOUNCE_MS = 1000

---@type table<string, string[]>|nil  ft -> ordered list of formatter names
local ft_map = nil

---Scan lua/configs/formatters/ and build the ft -> formatters map.
local function build_ft_map()
    ft_map = {}
    local by_ft = {}
    local dir = fn.stdpath("config") .. "/lua/configs/formatters"

    -- Guard against a missing formatters directory (e.g. fresh checkout).
    if fn.isdirectory(dir) == 0 then
        return
    end

    for entry, kind in fs.dir(dir) do
        if kind == "file" then
            local name = entry:match("^(.-)%.lua$")
            if name then
                local ok, mod = pcall(require, "configs.formatters." .. name)
                if ok and mod.filetype then
                    local fts = type(mod.filetype) == "string" and { mod.filetype } or mod.filetype
                    local priority = mod.priority or math.huge
                    for _, ft in ipairs(fts) do
                        by_ft[ft] = by_ft[ft] or {}
                        by_ft[ft][#by_ft[ft] + 1] = { name = name, priority = priority }
                    end
                end
            end
        end
    end

    for ft, entries in pairs(by_ft) do
        table.sort(entries, function(a, b) return a.priority < b.priority end)
        ft_map[ft] = vim.tbl_map(function(e) return e.name end, entries)
    end
end

---Return the ordered list of formatter names for a buffer's filetype.
---Checks compound filetypes first (e.g. "markdown.mdx"), then components,
---then the catch-all "_".
---@param bufnr integer
---@return string[]
local function names_for_buffer(bufnr)
    if not ft_map then
        build_ft_map()
    end

    local ft = bo[bufnr].filetype
    -- Empty filetype: no formatter can match; skip the split entirely.
    if ft == "" then
        return {}
    end

    local parts = vim.split(ft, ".", { plain = true })
    local candidates = { ft }
    for i = #parts, 1, -1 do
        candidates[#candidates + 1] = parts[i]
    end
    candidates[#candidates + 1] = "_"

    local seen, result = {}, {}
    for _, candidate in ipairs(candidates) do
        for _, name in ipairs(ft_map[candidate] or {}) do
            if not seen[name] then
                seen[name] = true
                result[#result + 1] = name
            end
        end
    end
    return result
end

---@class fmt.Context
---@field buf integer
---@field filename string  Absolute path (fabricated for unnamed buffers)
---@field dirname string
---@field shiftwidth integer

---@param bufnr integer  Must be a valid, non-zero buffer number.
---@return fmt.Context
local function build_context(bufnr)
    local ft_to_ext = require("utils.conform.ft_to_ext")

    local filename = api.nvim_buf_get_name(bufnr)
    local shiftwidth = bo[bufnr].shiftwidth
    if shiftwidth == 0 then
        shiftwidth = bo[bufnr].tabstop
    end

    local dirname
    if filename == "" or bo[bufnr].buftype ~= "" then
        dirname = uv.cwd()
        local ext = ft_to_ext[bo[bufnr].filetype] or bo[bufnr].filetype
        filename = fs.joinpath(dirname, "unnamed_temp." .. ext)
    else
        dirname = fs.dirname(filename)
    end

    return { buf = bufnr, filename = filename, dirname = dirname, shiftwidth = shiftwidth }
end

---Build the argv for a formatter's shell command.
---Substitutes $FILENAME and $DIRNAME in args.
---@param ctx fmt.Context
---@param config table
---@return string[]
local function build_cmd(ctx, config)
    local command = type(config.command) == "function" and config.command(config, ctx) or config.command
    local exe = fn.exepath(command)
    if exe ~= "" then
        command = exe
    end

    local args = config.args or {}
    if type(args) == "function" then
        args = args(config, ctx)
    end

    local subs = { ["$FILENAME"] = ctx.filename, ["$DIRNAME"] = ctx.dirname }
    local cmd = { command }
    for _, v in ipairs(args) do
        cmd[#cmd + 1] = subs[v] or v
    end
    return cmd
end

---Run one formatter synchronously against input_lines.
---Returns the new lines on success, nil on error (error already notified).
---@param bufnr integer
---@param name string
---@param config table
---@param ctx fmt.Context
---@param input_lines string[]
---@return string[]|nil
local function run_one(bufnr, name, config, ctx, input_lines)
    local eol_line = bo[bufnr].eol and "\n" or ""
    local original_text = table.concat(input_lines, "\n") .. eol_line
    local cmd = build_cmd(ctx, config)
    ---cwd resolution order:
    ---  1. config.cwd fn — escape hatch for formatters with unusual needs
    ---  2. config.root_markers — walk upward from the file's directory; standard
    ---  3. ctx.dirname — file's own directory; safer fallback than Neovim's cwd
    ---@type string?
    local cwd
    if type(config.cwd) == "function" then
        cwd = config.cwd(config, ctx)
    elseif config.root_markers then
        cwd = fs.root(ctx.dirname, config.root_markers)
    end
    cwd = cwd or ctx.dirname
    local env = type(config.env) == "function" and config.env(config, ctx) or config.env

    local ok, obj = pcall(vim.system, cmd, { cwd = cwd, env = env, stdin = original_text, text = true })
    if not ok then
        vim.notify(("[fmt] '%s' failed to start: %s"):format(name, obj), vim.log.levels.ERROR)
        return nil
    end

    local result = obj:wait(5000)

    -- SystemObj:wait() kills the process itself (SIGKILL) and returns with code = 124
    if result.code == 124 then
        vim.notify(("[fmt] '%s' timed out after 5s"):format(name), vim.log.levels.ERROR)
        return nil
    end

    -- Some formatters exit non-zero even on success (e.g. eslint_d exits 1
    -- when it fixed issues). exit_codes lists every code to treat as success;
    -- defaults to { 0 } when not specified.
    local accepted_codes = config.exit_codes or { 0 }
    if not vim.tbl_contains(accepted_codes, result.code) then
        local stderr = (result.stderr or ""):gsub("%s+$", "")
        if stderr ~= "" then
            vim.notify(
                ("[fmt] '%s' exited %d: %s"):format(name, result.code, stderr),
                vim.log.levels.ERROR
            )
        end
        return nil
    end

    local stdout = result.stdout or ""

    -- Guard: some formatters (e.g. black with --force-exclude) exit 0 but emit
    -- empty stdout for files they are configured to skip. Applying empty output
    -- would wipe the buffer. Abort if the output is whitespace-only but the
    -- original was not.
    if stdout:match("^%s*$") and not original_text:match("^%s*$") then
        vim.notify(
            ("[fmt] '%s' returned empty output; aborting to avoid buffer wipe"):format(name),
            vim.log.levels.WARN
        )
        return nil
    end

    -- Split on \n or \r\n (some formatters on non-Unix CWDs emit \r\n).
    -- sep is treated as a Lua pattern by vim.split by default.
    local output = vim.split(stdout, "\r?\n")
    -- Strip the one trailing empty string that vim.split produces for a
    -- newline-terminated string (the final EOL itself, not a blank line).
    if eol_line ~= "" and output[#output] == "" then
        table.remove(output)
    end
    if #output == 0 then
        output[1] = ""
    end
    return output
end

-- Forward declaration so M.format can reference it before assignment.
local format_debounced

---Format a buffer immediately (no debounce).
---Called from BufWritePre (autocmd) and from the debounced keymap path.
---Silently skips buffers with no configured formatter.
---@param bufnr? integer
M.format_no_wait = function(bufnr)
    -- Normalize nil/0 → current buffer. bo[0] works but is an implicit
    -- current-buffer access; we want an explicit bufnr for all subsequent calls.
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end

    -- Guard: buffer may have been wiped between the debounce arming and firing
    -- (1000 ms window in the keymap path). Accessing bo[] on an invalid buffer
    -- in names_for_buffer would error.
    if not api.nvim_buf_is_valid(bufnr) then
        return
    end

    local names = names_for_buffer(bufnr)
    if vim.tbl_isempty(names) then
        return
    end

    local ctx = build_context(bufnr)

    -- Validate all formatters before running any of them: check condition,
    -- then executable. Collect the passing subset into `formatters`.
    local formatters = {}
    for _, name in ipairs(names) do
        local ok, config = pcall(require, "configs.formatters." .. name)
        if not ok then
            vim.notify(("[fmt] Failed to load config for '%s': %s"):format(name, config), vim.log.levels.ERROR)
            return
        end

        -- condition(self, ctx): optional predicate. Returning false skips this
        -- formatter silently (e.g. "only run if .prettierrc exists").
        if type(config.condition) == "function" and not config.condition(config, ctx) then
            goto continue
        end

        local cmd_str = type(config.command) == "function" and config.command(config, ctx) or config.command
        if fn.executable(cmd_str) == 0 then
            vim.notify(("[fmt] '%s': command '%s' not found"):format(name, cmd_str), vim.log.levels.ERROR)
            return
        end

        formatters[#formatters + 1] = { name = name, config = config }

        ::continue::
    end

    if vim.tbl_isempty(formatters) then
        return
    end

    local original = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local lines = vim.deepcopy(original)

    for _, f in ipairs(formatters) do
        local result = run_one(bufnr, f.name, f.config, ctx, lines)
        if not result then
            -- One formatter in the chain failed; abort the whole chain so we
            -- never apply a partially-formatted state.
            return
        end
        lines = result
    end

    diff.apply_format(bufnr, original, lines)
end

---Format a buffer with a debounce. Called from the keymap.
---@param bufnr? integer
M.format = function(bufnr)
    if not bufnr or bufnr == 0 then
        bufnr = api.nvim_get_current_buf()
    end
    return format_debounced(bufnr)
end

format_debounced = utils.debounce_by_key(function(bufnr) M.format_no_wait(bufnr) end, DEBOUNCE_MS)

return M
