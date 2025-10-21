local M = {}

local colors = require("utils.completions.highlights.colors")

M.setup_highlights = function()
    -- Popup menu colors
    vim.api.nvim_set_hl(0, "Pmenu", { bg = colors.bg, fg = colors.fg })
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.yellow, fg = colors.black })
    vim.api.nvim_set_hl(0, "PmenuSbar", { bg = colors.gray })
    vim.api.nvim_set_hl(0, "PmenuThumb", { bg = colors.dark_gray })
    vim.api.nvim_set_hl(0, "PmenuKind", { bg = colors.bg, fg = colors.blue })
    vim.api.nvim_set_hl(0, "PmenuKindSel", { bg = colors.yellow, fg = colors.dark_blue })

    -- Matched text highlighting
    vim.api.nvim_set_hl(0, "PmenuMatch", { bg = colors.bg, fg = colors.red })
    vim.api.nvim_set_hl(0, "PmenuMatchSel", { bg = colors.yellow, fg = colors.dark_red })
end

return M
