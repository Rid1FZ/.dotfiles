---@class Utils
local M = {}

local contains = vim.tbl_contains
local wo = vim.wo -- always use the index form: wo[something]
local bo = vim.bo -- always use the index form: bo[something]
local api = vim.api
local log_levels = vim.log.levels
local notify = vim.notify
local treesitter = vim.treesitter
local schedule = vim.schedule
local format = string.format
local defer_fn = vim.defer_fn

---Set highlighting
---@param name string The highlight group name
---@param val vim.api.keyset.highlight The highlight attributes
---@return nil
M.highlight = function(name, val) api.nvim_set_hl(0, name, val) end

---Trailing-edge debounce for a single-instance timer.
---Returns the debounced function and a cancel function.
---@param fn function
---@param ms integer
---@return fun(...), fun()
M.debounce = function(fn, ms)
    local timer = nil

    local function cancel()
        if timer then
            timer:stop()
            timer:close()
            timer = nil
        end
    end

    local function executor(...)
        local args = { ... }

        cancel()
        timer = defer_fn(function()
            timer = nil
            fn(unpack(args))
        end, ms)
    end

    return executor, cancel
end

---Trailing-edge debounce keyed by an arbitrary value (e.g. bufnr).
---All timers share one table managed inside the closure.
---@param fn fun(key: any, ...)
---@param ms integer
---@return fun(key: any, ...)
M.debounce_by_key = function(fn, ms)
    local timers = {}

    return function(key, ...)
        local t = timers[key]
        if t then
            t:stop()
            t:close()
        end

        local args = { ... }
        timers[key] = defer_fn(function()
            timers[key] = nil
            fn(key, unpack(args))
        end, ms)
    end
end

---Start treesitter for current buffer
---@param bufnr integer Buffer number
---@param winnr integer Window number
---@return nil
M.start_treesitter = function(bufnr, winnr)
    -- local filetype = bo[bufnr].filetype
    -- local parser = treesitter.get_parser(bufnr, nil, { error = false })
    --
    -- if not parser then
    --     local nvim_treesitter = require("nvim-treesitter") -- do not require unless needed
    --     if not contains(nvim_treesitter.get_available(), filetype) then
    --         return
    --     end
    --
    --     notify(format("installing '%s' treesitter parser...", filetype), log_levels.INFO)
    --     nvim_treesitter.install(filetype):wait(30000)
    -- end

    treesitter.start(bufnr)
    wo[winnr][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
end

---Load keymappings for specific plugin
---@param section? string
---@param mapping_opt? table
---@return nil
M.load_mappings = function(section, mapping_opt)
    if not section then
        section = "general"
    end
    if not mapping_opt then
        mapping_opt = {}
    end

    schedule(function()
        local mappings = require("mappings")
        mappings[section](mapping_opt)
    end)
end

return M
