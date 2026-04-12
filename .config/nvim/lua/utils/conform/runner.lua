---Core execution engine: builds commands, runs formatters, applies diffs.
---All formatting is synchronous. No async, no ranges.
---@class Runner
local M = {}

local fs = require("utils.conform.fs")
local ft_to_ext = require("utils.conform.ft_to_ext")
local util = require("utils.conform.util")

---@type fun(a: string, b: string, opts: table): any
local vim_diff = vim.text.diff

---@class fmt.Context
---@field buf integer Buffer handle
---@field filename string Absolute path (may be a fabricated temp name for unnamed bufs)
---@field dirname string Directory containing the file
---@field shiftwidth integer Resolved shiftwidth (falls back to tabstop if shiftwidth=0)

---@class fmt.FormatterEntry
---@field name string Formatter name (matches configs/formatters/<name>.lua)
---@field config table Pre-resolved formatter config (passed in by init.lua)

---Emit a user-visible error notification.
---@param msg string
local function err(msg) vim.notify("[fmt] " .. msg, vim.log.levels.ERROR) end

---Build the argv table for a formatter's shell command.
---Expands $FILENAME, $DIRNAME, $RELATIVE_FILEPATH, $EXTENSION in both string
---and table args forms.
---@param name string Formatter name (used in error messages only)
---@param ctx fmt.Context
---@param config table Resolved formatter config
---@return string[]
M.build_cmd = function(name, ctx, config)
    local command = type(config.command) == "function" and config.command(config, ctx) or config.command

    -- Prefer the full executable path so we don't rely on $PATH resolution
    -- inside vim.system.
    local exe = vim.fn.exepath(command)
    if exe ~= "" then
        command = exe
    end

    local args = config.args or {}
    if type(args) == "function" then
        args = args(config, ctx)
    end

    -- Lazy: only compute relative filepath when actually referenced.
    local function rel()
        local cwd = config.cwd and config.cwd(config, ctx)
        return fs.relative_path(cwd or vim.fn.getcwd(), ctx.filename)
    end

    -- Token → value map. Values that are functions are called lazily.
    local subs = {
        ["$FILENAME"] = ctx.filename,
        ["$DIRNAME"] = ctx.dirname,
        ["$RELATIVE_FILEPATH"] = rel, ---@type string|fun(): string
        ["$EXTENSION"] = ctx.filename:match(".*(%..*)$") or "",
    }

    if type(args) == "string" then
        -- Shell-string form: interpolate tokens then split via shell rules.
        -- Pattern: $UPPER_WITH_UNDERSCORES
        local interpolated = args:gsub("%$[%u_]+", function(k)
            local v = subs[k]
            return type(v) == "function" and v() or (v or k)
        end)
        return util.shell_build_argv(command .. " " .. interpolated)
    end

    -- Table form: substitute token strings in place.
    local cmd = { command }
    for _, v in ipairs(args) do
        local s = subs[v]
        cmd[#cmd + 1] = s and (type(s) == "function" and s() or s) or v
    end
    return cmd
end

---Build the context table passed to formatter config functions.
---For unnamed or non-file buffers a synthetic filename is fabricated so that
---$FILENAME args still work (e.g. for formatters that infer language from
---the extension).
---@param bufnr integer
---@param config table   Resolved formatter config (used to check stdin flag)
---@return fmt.Context
M.build_context = function(bufnr, config)
    if bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local filename = vim.api.nvim_buf_get_name(bufnr)
    local shiftwidth = vim.bo[bufnr].shiftwidth
    if shiftwidth == 0 then
        shiftwidth = vim.bo[bufnr].tabstop
    end

    -- Non-file buffers (checkhealth, scratch, …): fabricate a filename.
    if vim.bo[bufnr].buftype ~= "" then
        filename = ""
    end

    ---@type string
    local dirname
    if filename == "" then
        dirname = vim.fn.getcwd()
        filename = fs.join(dirname, "unnamed_temp")
        local ft = vim.bo[bufnr].filetype
        if ft ~= "" then
            filename = filename .. "." .. (ft_to_ext[ft] or ft)
        end
    else
        dirname = vim.fs.dirname(filename)
    end

    return {
        buf = bufnr,
        filename = filename,
        dirname = dirname,
        shiftwidth = shiftwidth,
    }
end

---Uses vim.diff (histogram algorithm) to compute minimal LSP TextEdits rather
---than replacing the entire buffer. This preserves cursor position, folds,
---extmarks, and undo history granularity.
---@param a? string
---@param b? string
---@return integer
local function common_prefix_len(a, b)
    if not a or not b then
        return 0
    end
    local n = math.min(#a, #b)
    for i = 1, n do
        if a:byte(i) ~= b:byte(i) then
            return i - 1
        end
    end
    return n
end

---@param a string
---@param b string
---@return integer
local function common_suffix_len(a, b)
    local al, bl = #a, #b
    local n = math.min(al, bl)
    for i = 0, n - 1 do
        if a:byte(al - i) ~= b:byte(bl - i) then
            return i
        end
    end
    return n
end

---Convert a single diff hunk into an LSP TextEdit object.
---@param orig string[] Original buffer lines (1-indexed)
---@param repl string[] Replacement lines
---@param is_insert boolean
---@param is_replace boolean
---@param ls integer Line start (1-indexed, inclusive)
---@param le integer Line end   (1-indexed, inclusive)
---@param eol string Line ending for this buffer
---@return table LSP TextEdit
local function make_edit(orig, repl, is_insert, is_replace, ls, le, eol)
    local sc, ec = 0, 0
    if is_replace then
        -- Trim common prefix/suffix to produce a smaller edit.
        sc = common_prefix_len(orig[ls], repl[1])
        if sc > 0 then
            repl[1] = repl[1]:sub(sc + 1)
        end
        if orig[le] then
            local last = repl[#repl]
            local suffix = common_suffix_len(orig[le], last)
            -- Avoid overlap when start == end.
            if le == ls then
                suffix = math.min(suffix, #orig[le] - sc)
            end
            ec = #orig[le] - suffix
            if suffix > 0 then
                repl[#repl] = last:sub(1, #last - suffix)
            end
        end
    end
    -- Inserts need a trailing newline sentinel unless they are at EOF.
    if is_insert and ls - 1 < #orig then
        repl[#repl + 1] = ""
    end
    return {
        newText = table.concat(repl, eol),
        range = {
            start = { line = ls - 1, character = sc },
            ["end"] = { line = le - 1, character = ec },
        },
    }
end

---Diff original vs new_lines and apply minimal edits to the buffer.
---@param bufnr integer
---@param original string[] Original lines (will NOT be mutated)
---@param new_lines string[] Formatter output lines (will NOT be mutated)
---@return boolean did_edit
local function apply_format(bufnr, original, new_lines)
    if not vim.api.nvim_buf_is_valid(bufnr) then
        return false
    end

    -- Append a sentinel empty line so that trailing-newline changes are
    -- represented as a diff hunk rather than being silently ignored.
    local orig_text = table.concat(original, "\n") .. "\n"
    local new_text = table.concat(new_lines, "\n") .. "\n"

    -- Guard: refuse to wipe a non-empty buffer with empty output.
    if new_text:match("^%s*$") and not orig_text:match("^%s*$") then
        err("Formatter returned empty output — refusing to wipe buffer")
        return false
    end

    ---@diagnostic disable-next-line: missing-fields
    local indices = vim_diff(orig_text, new_text, {
        result_type = "indices",
        algorithm = "histogram",
    })
    assert(type(indices) == "table", "vim.diff returned unexpected type")

    local edits = {}
    local eol = util.buf_line_ending(bufnr)

    for _, idx in ipairs(indices) do
        local orig_start, orig_count, new_start, new_count = unpack(idx)
        local is_insert = orig_count == 0
        local is_delete = new_count == 0
        local is_replace = not is_insert and not is_delete
        local orig_end = orig_start + orig_count
        local repl = util.tbl_slice(new_lines, new_start, new_start + new_count - 1)

        if is_replace then
            orig_end = orig_end - 1
        end
        if is_insert then
            orig_start = orig_start + 1
            orig_end = orig_end + 1
        end

        edits[#edits + 1] = make_edit(original, repl, is_insert, is_replace, orig_start, orig_end, eol)
    end

    if not vim.tbl_isempty(edits) then
        vim.lsp.util.apply_text_edits(edits, bufnr, "utf-8")
    end
    return not vim.tbl_isempty(edits)
end

---Run a single formatter synchronously against a list of lines.
---Returns the new lines on success, nil on any error (error already notified).
---@param bufnr integer
---@param name string    Formatter name
---@param config table     Resolved formatter config
---@param ctx fmt.Context
---@param input_lines string[]  Lines to format (not mutated)
---@return string[]|nil
local function run_one(bufnr, name, config, ctx, input_lines)
    if config.format then
        local result, cb_err
        local ok, lua_err = pcall(config.format, config, ctx, input_lines, function(e, lines)
            cb_err = e
            result = lines
        end)
        if not ok then
            err(("Formatter '%s' threw: %s"):format(name, lua_err))
            return nil
        end
        if cb_err then
            err(("Formatter '%s' error: %s"):format(name, cb_err))
            return nil
        end
        return result
    end

    -- Build stdin: append a trailing newline if the buffer has 'eol' set,
    -- matching what Neovim would write to disk.
    local eol_line = vim.bo[bufnr].eol and "\n" or ""
    local stdin_text = table.concat(input_lines, "\n") .. eol_line

    local cmd = M.build_cmd(name, ctx, config)
    local cwd = config.cwd and config.cwd(config, ctx) or nil
    local env = type(config.env) == "function" and config.env(config, ctx) or config.env
    local exit_codes = config.exit_codes or { 0 }

    -- Use vim.system():wait(timeout) — the documented synchronous pattern.
    -- No vim.schedule_wrap callback or vim.wait polling needed.
    local ok, obj = pcall(vim.system, cmd, {
        cwd = cwd,
        env = env,
        stdin = stdin_text,
        text = true,
    })

    if not ok then
        err(("Formatter '%s' failed to start: %s"):format(name, obj))
        return nil
    end

    ---@type vim.SystemCompleted
    local result = obj:wait(5000)

    -- A nil code means the wait timed out (process still running).
    if result.code == nil then
        obj:kill(9)
        err(("Formatter '%s' timed out after 5s"):format(name))
        return nil
    end

    if not vim.tbl_contains(exit_codes, result.code) then
        local stdout = result.stdout and vim.split(result.stdout, "\r?\n") or {}
        local stderr = result.stderr and vim.split(result.stderr, "\r?\n") or {}
        local function nonempty(t) return #t > 0 and not (#t == 1 and t[1] == "") end
        local msg = nonempty(stderr) and table.concat(stderr, "\n")
            or nonempty(stdout) and table.concat(stdout, "\n")
            or "unknown error"
        err(("Formatter '%s' exited %d: %s"):format(name, result.code, msg))
        return nil
    end

    -- Split stdout back into lines, stripping the trailing newline that most
    -- formatters append (so that our lines table matches Neovim's representation).
    local output = result.stdout and vim.split(result.stdout, "\r?\n") or { "" }
    if eol_line ~= "" and output[#output] == "" then
        table.remove(output)
    end
    if #output == 0 then
        output[1] = ""
    end

    return output
end

---Run all formatters in sequence and apply the result to the buffer.
---Each formatter receives the output of the previous one as its input.
---
---`formatters` entries must have `name` (string) and `config` (table)
---pre-resolved by init.lua — this function does not call back into init.
---
---@param bufnr integer
---@param formatters fmt.FormatterEntry[]
---@return boolean did_edit  True if the buffer was changed.
M.format_sync = function(bufnr, formatters)
    if bufnr == 0 then
        bufnr = vim.api.nvim_get_current_buf()
    end

    local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local lines = vim.deepcopy(original)

    for _, formatter in ipairs(formatters) do
        local ctx = M.build_context(bufnr, formatter.config)
        local result = run_one(bufnr, formatter.name, formatter.config, ctx, lines)
        if not result then
            return false
        end
        lines = result
    end

    return apply_format(bufnr, original, lines)
end

return M
