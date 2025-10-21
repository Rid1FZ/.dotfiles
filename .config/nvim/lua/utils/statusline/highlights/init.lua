local M = {}
local colors = require("utils.statusline.highlights.colors")

M.setup_highlights = function()
    -- Default statusline
    vim.api.nvim_set_hl(0, "StatusLine", { bg = colors.bg, fg = colors.fg })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = colors.bg, fg = colors.fg })

    -- Border highlight
    vim.api.nvim_set_hl(0, "StatusLineBorder", { bg = colors.bg, fg = colors.blue })

    -- Mode highlights
    vim.api.nvim_set_hl(0, "StatuslineAccent", { fg = colors.fg, bg = colors.bg, bold = true })
    vim.api.nvim_set_hl(0, "StatuslineInsertAccent", { fg = colors.green, bg = colors.bg, bold = true })
    vim.api.nvim_set_hl(0, "StatuslineVisualAccent", { fg = colors.blue, bg = colors.bg, bold = true })
    vim.api.nvim_set_hl(0, "StatuslineReplaceAccent", { fg = colors.red, bg = colors.bg, bold = true })
    vim.api.nvim_set_hl(0, "StatuslineTerminalAccent", { fg = colors.magenta, bg = colors.bg, bold = true })
    vim.api.nvim_set_hl(0, "StatuslineCmdLineAccent", { fg = colors.orange, bg = colors.bg, bold = true })

    -- LSP diagnostic highlights
    vim.api.nvim_set_hl(0, "LspDiagnosticsSignError", { bg = colors.bg, fg = colors.red })
    vim.api.nvim_set_hl(0, "LspDiagnosticsSignWarning", { bg = colors.bg, fg = colors.yellow })
    vim.api.nvim_set_hl(0, "LspDiagnosticsSignInformation", { bg = colors.bg, fg = colors.cyan })
    vim.api.nvim_set_hl(0, "LspDiagnosticsSignHint", { bg = colors.bg, fg = colors.blue })

    -- Git branch highlighting
    vim.api.nvim_set_hl(0, "StatusLineGitBranch", { bg = colors.bg, fg = colors.magenta })

    -- Extra statusline section
    vim.api.nvim_set_hl(0, "StatusLineExtra", { bg = colors.bg, fg = colors.fg })
end

return M
