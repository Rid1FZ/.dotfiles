---Public API for fmt.nvim.
---
---Usage:
--- local fmt = require("utils.conform")
--- fmt.formatters_by_ft  -- discovered automatically from configs/formatters/
--- fmt.formatters.black = { append_args = { "--line-length", "100" } }
--- fmt.format()
---@class Conform
local M = {}

---Per-formatter config overrides. Merges on top of configs/formatters/<name>.lua.
---Set directly, e.g.:
---  require("utils.conform").formatters.black = { append_args = { "--line-length", "100" } }
---@type table<string, table|fun(bufnr: integer): table>
M.formatters = {}

---Scanned once on the first format() call then cached.
---Each file in configs/formatters/ declares its own `filetype` and `priority`.
---@type table<string, string[]>|nil  ft → ordered list of formatter names
local ft_map = nil

---Scan lua/configs/formatters/ and build the ft -> formatters map.
---@return nil
local function build_ft_map()
    ft_map = {}
    ---@type table<string, {name: string, priority: integer}[]>
    local by_ft = {}
    local dir_path = vim.fn.stdpath("config") .. "/lua/configs/formatters"

    for entry_name, entry_type in vim.fs.dir(dir_path) do
        if entry_type ~= "file" then
            goto loop_exit
        end

        local name = entry_name:match("^(.-)%.lua$")
        if not name then
            goto loop_exit
        end

        local ok, mod = pcall(require, "configs.formatters." .. name)
        if not ok then
            vim.notify(("[fmt] Failed to load configs.formatters.%s: %s"):format(name, mod), vim.log.levels.ERROR)
        elseif mod.filetype then
            local fts = type(mod.filetype) == "string" and { mod.filetype } or mod.filetype
            local priority = mod.priority or math.huge
            for _, ft in ipairs(fts) do
                by_ft[ft] = by_ft[ft] or {}
                by_ft[ft][#by_ft[ft] + 1] = { name = name, priority = priority }
            end
        end

        ::loop_exit:: -- this label must be at the end
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

    local ft = vim.bo[bufnr].filetype
    local parts = vim.split(ft, ".", { plain = true })

    -- Priority order: full compound > components in reverse > "_"
    local candidates = { ft }
    for i = #parts, 1, -1 do
        candidates[#candidates + 1] = parts[i]
    end
    candidates[#candidates + 1] = "_"

    local seen, result = {}, {}
    for _, candidate in ipairs(candidates) do
        for _, name in ipairs((ft_map and ft_map[candidate]) or {}) do
            if not seen[name] then
                seen[name] = true
                result[#result + 1] = name
            end
        end
    end

    return result
end

-- ── Config resolution ─────────────────────────────────────────────────────────

---Load and merge a formatter's config.
---
---Resolution order:
---  1. Load base from configs/formatters/<name>.lua
---  2. Merge any entry from M.formatters[name] on top (respects prepend_args /
---     append_args / inherit semantics)
---
---Returns nil and emits vim.notify on any configuration error.
---@param name string
---@param bufnr? integer Defaults to current buffer
---@return table|nil config
M.get_formatter_config = function(name, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local override = M.formatters[name]
    if type(override) == "function" then
        override = override(bufnr)
    end

    -- Sanity: a formatter can use a job command OR a Lua format function, not both.
    if override and override.command and override.format then
        vim.notify(
            ("[fmt] Formatter '%s': cannot define both 'command' and 'format'"):format(name),
            vim.log.levels.ERROR
        )
        return nil
    end

    -- inherit = true -> merge override on top of configs/formatters/<name>.lua
    -- inherit = false -> use only the override (no base file needed)
    -- inherit = "other" -> merge override on top of configs/formatters/other.lua
    local inherit = (override == nil) or (override.inherit == nil) or override.inherit
    if inherit == false then
        inherit = false
    else
        inherit = override and override.inherit or true
    end

    local config
    if inherit then
        local parent = type(inherit) == "string" and inherit or name
        local ok, base = pcall(require, "configs.formatters." .. parent)
        if not ok then
            -- No built-in — allow a fully-specified override with command/format.
            if override and (override.command or override.format) then
                config = override
            else
                vim.notify(
                    ("[fmt] Formatter '%s': no config at configs.formatters.%s"):format(name, parent),
                    vim.log.levels.ERROR
                )
                return nil
            end
        else
            config = override and require("utils.conform.util").merge_formatter_configs(base, override) or base
        end
    else
        if not override then
            vim.notify(("[fmt] Formatter '%s': inherit=false but no override set"):format(name), vim.log.levels.ERROR)
            return nil
        end
        config = override
    end

    -- Default stdin=true: most formatters read from stdin / write to stdout.
    if config.stdin == nil then
        config.stdin = true
    end
    return config
end

---Load configs and check executable availability for a list of formatter names.
---Returns nil (and has already notified) on the first problem encountered.
---@param names string[]
---@param bufnr integer
---@return {name: string, config: table}[]|nil
local function resolve(names, bufnr)
    local runner = require("utils.conform.runner")
    local result = {}

    for _, name in ipairs(names) do
        local config = M.get_formatter_config(name, bufnr)
        if not config then
            return nil
        end

        -- For job formatters, verify the executable exists before we try to run.
        if not config.format then
            local cmd_str = config.command
            if type(cmd_str) == "function" then
                cmd_str = cmd_str(config, runner.build_context(bufnr, config))
            end
            if vim.fn.executable(cmd_str) == 0 then
                vim.notify(("[fmt] Formatter '%s': command '%s' not found"):format(name, cmd_str), vim.log.levels.ERROR)
                return nil
            end

            if config.condition then
                local ctx = runner.build_context(bufnr, config)
                if not config.condition(config, ctx) then
                    vim.notify(("[fmt] Formatter '%s': condition failed"):format(name), vim.log.levels.ERROR)
                    return nil
                end
            end

            if config.require_cwd and config.cwd then
                local ctx = runner.build_context(bufnr, config)
                if not config.cwd(config, ctx) then
                    vim.notify(("[fmt] Formatter '%s': root directory not found"):format(name), vim.log.levels.ERROR)
                    return nil
                end
            end
        end

        result[#result + 1] = { name = name, config = config }
    end

    return result
end

---Format a buffer synchronously using formatters auto-discovered from
---configs/formatters/ via the `filetype` field.
---
---Formatters for the same filetype run in `priority` order (lowest first).
---Multiple formatters are chained: each receives the output of the previous.
---
---Errors (missing command, non-zero exit, …) are surfaced via vim.notify
---and abort the chain — the buffer is left in whatever state the last
---successful formatter (or no formatter) produced.
---
---@param bufnr? integer Buffer to format. Defaults to current buffer (0).
M.format = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local names = names_for_buffer(bufnr)
    if vim.tbl_isempty(names) then
        vim.notify(
            ("[fmt] No formatters configured for filetype '%s'"):format(vim.bo[bufnr].filetype),
            vim.log.levels.ERROR
        )
        return
    end

    local formatters = resolve(names, bufnr)
    if not formatters then
        return
    end

    require("utils.conform.runner").format_sync(bufnr, formatters)
end

return M
