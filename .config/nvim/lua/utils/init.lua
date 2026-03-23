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

---Set highlighting
---@param name string The highlight group name
---@param val vim.api.keyset.highlight The highlight attributes
---@return nil
M.highlight = function(name, val) api.nvim_set_hl(0, name, val) end

---Start treesitter for current buffer
---@param bufnr integer Buffer number
---@param winnr integer Window number
---@return nil
M.start_treesitter = function(bufnr, winnr)
    local filetype = bo[bufnr].filetype
    local parser_available, _ = pcall(treesitter.get_parser, bufnr) -- NOTE: change this in Neovim 0.12

    if not parser_available then
        local nvim_treesitter = require("nvim-treesitter") -- do not require unless needed
        if not contains(nvim_treesitter.get_available(), filetype) then
            return
        end

        notify(format("installing '%s' treesitter parser...", filetype), log_levels.INFO)
        nvim_treesitter.install(filetype):wait(30000)
    end

    treesitter.start(bufnr)
    wo[winnr].foldexpr = "v:lua.vim.treesitter.foldexpr()"
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
