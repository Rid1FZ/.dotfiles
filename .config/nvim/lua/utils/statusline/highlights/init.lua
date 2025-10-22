local M = {}
local colors = require("utils.statusline.highlights.colors")
local highlight = require("utils").highlight

M.setup_highlights = function()
    -- Default statusline
    highlight("StatusLine", { bg = colors.bg, fg = colors.fg })
    highlight("StatusLineNC", { bg = colors.bg, fg = colors.fg })

    -- Border highlight
    highlight("StatusLineBorder", { bg = colors.bg, fg = colors.blue })

    -- Mode highlights
    highlight("StatuslineAccent", { fg = colors.fg, bg = colors.bg, bold = true })
    highlight("StatuslineInsertAccent", { fg = colors.green, bg = colors.bg, bold = true })
    highlight("StatuslineVisualAccent", { fg = colors.blue, bg = colors.bg, bold = true })
    highlight("StatuslineReplaceAccent", { fg = colors.red, bg = colors.bg, bold = true })
    highlight("StatuslineTerminalAccent", { fg = colors.magenta, bg = colors.bg, bold = true })
    highlight("StatuslineCmdLineAccent", { fg = colors.orange, bg = colors.bg, bold = true })

    -- LSP diagnostic highlights
    highlight("LspDiagnosticsSignError", { bg = colors.bg, fg = colors.red })
    highlight("LspDiagnosticsSignWarning", { bg = colors.bg, fg = colors.yellow })
    highlight("LspDiagnosticsSignInformation", { bg = colors.bg, fg = colors.cyan })
    highlight("LspDiagnosticsSignHint", { bg = colors.bg, fg = colors.blue })

    -- Git branch highlighting
    highlight("StatusLineGitBranch", { bg = colors.bg, fg = colors.magenta })

    -- Extra statusline section
    highlight("StatusLineExtra", { bg = colors.bg, fg = colors.fg })
end

return M
