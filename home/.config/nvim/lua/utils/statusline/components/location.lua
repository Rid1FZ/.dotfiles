---@class StatuslineLocation
local M = {}

---Get cursor location component
---Shows current position as: percentage% line:column
---@return string Statusline format string with cursor position
M.get_location = function()
    return "%3p%% %3l:%-3c"
end

return M
