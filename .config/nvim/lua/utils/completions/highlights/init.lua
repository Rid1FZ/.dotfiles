---@class Highlight
local M = {}

local colors = require("utils.completions.highlights.colors")
local highlight = require("utils").highlight

---Setup highlightings for vim.lsp.completion popup
---@return nil
M.setup_highlights = function()
    -- Popup menu colors
    highlight("Pmenu", { bg = colors.bg, fg = colors.fg })
    highlight("PmenuSel", { bg = colors.yellow, fg = colors.black })
    highlight("PmenuSbar", { bg = colors.gray })
    highlight("PmenuThumb", { bg = colors.dark_gray })
    highlight("PmenuKind", { bg = colors.bg, fg = colors.blue })
    highlight("PmenuKindSel", { bg = colors.yellow, fg = colors.dark_blue })

    -- Matched text highlighting
    highlight("PmenuMatch", { bg = colors.bg, fg = colors.red })
    highlight("PmenuMatchSel", { bg = colors.yellow, fg = colors.dark_red })
end

return M
