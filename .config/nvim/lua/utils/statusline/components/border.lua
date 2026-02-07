---@class StatuslineBorder
local M = {}

---Get the left border component
---@return string Statusline format string for left border
M.get_left_border = function()
    return "%#StatusLineBorder#█ "
end

---Get the right border component
---@return string Statusline format string for right border
M.get_right_border = function()
    return " %#StatusLineBorder#█"
end

return M
