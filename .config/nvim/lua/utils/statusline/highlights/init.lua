local M = {}
local colors = require("utils.statusline.highlights.colors")
local highlight = require("utils").highlight

local api = vim.api

----------------------------------------------------------------------
-- Highlight Setup
----------------------------------------------------------------------
M.setup_highlights = function()
    -- Core statusline
    highlight("StatusLine", { fg = colors.fg, bg = colors.bg })
    api.nvim_set_hl(0, "StatusLineNC", { link = "StatusLine" })

    -- Borders / separators
    highlight("StatusLineBorder", { fg = colors.blue })

    -- Mode-specific accents
    highlight("StatusLineAccent", { fg = colors.fg, bold = true })
    highlight("StatusLineInsertAccent", { fg = colors.green, bold = true })
    highlight("StatusLineVisualAccent", { fg = colors.blue, bold = true })
    highlight("StatusLineReplaceAccent", { fg = colors.red, bold = true })
    highlight("StatusLineTerminalAccent", { fg = colors.magenta, bold = true })
    highlight("StatusLineCmdLineAccent", { fg = colors.orange, bold = true })

    -- Modern diagnostic highlight groups
    highlight("DiagnosticSignError", { fg = colors.red })
    highlight("DiagnosticSignWarn", { fg = colors.yellow })
    highlight("DiagnosticSignInfo", { fg = colors.cyan })
    highlight("DiagnosticSignHint", { fg = colors.blue })

    -- Git branch section
    highlight("StatusLineGitBranch", { fg = colors.magenta })

    -- Additional section styling
    highlight("StatusLineExtra", { fg = colors.fg })
end

return M
