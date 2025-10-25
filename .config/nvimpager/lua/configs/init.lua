local M = {}

local utils = require("utils")

local api = vim.api

M.setup_autocommands = function()
    --------------------------------------------------------------------
    -- All augroups
    --------------------------------------------------------------------
    local groups = {
        yank = api.nvim_create_augroup("HighlightYank", { clear = true }),
        start_treesitter = api.nvim_create_augroup("StartTreesitter", { clear = true }),
    }

    --------------------------------------------------------------------
    -- Highlight yanked part
    --------------------------------------------------------------------
    api.nvim_create_autocmd("TextYankPost", {
        group = groups.yank,
        callback = function()
            vim.highlight.on_yank({ timeout = 150 })
        end,
    })

    --------------------------------------------------------------------
    -- Start treesitter when a file is opened
    --------------------------------------------------------------------
    api.nvim_create_autocmd("FileType", {
        group = groups.start_treesitter,
        callback = function()
            utils.start_treesitter()
        end,
    })
end

return M
