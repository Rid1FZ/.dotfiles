local M = {}

local contains = vim.tbl_contains
local log_levels = vim.log.levels
local notify = vim.notify

--------------------------------------------------------------------
-- Start treesitter for current buffer
--------------------------------------------------------------------
M.start_treesitter = function()
    local filetype = vim.bo.filetype
    local nvim_treesitter = require("nvim-treesitter")
    local parser_available, _ = pcall(vim.treesitter.get_parser) -- NOTE: change this in Neovim 0.12

    if not parser_available then
        if not contains(nvim_treesitter.get_available(), filetype) then
            return
        end

        notify(string.format("installing '%s' treesitter parser...", filetype), log_levels.INFO)
        nvim_treesitter.install(filetype):wait(30000)
    end

    vim.treesitter.start()
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

return M
