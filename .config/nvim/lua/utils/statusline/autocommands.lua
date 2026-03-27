---@class StatuslineAutocommands
local M = {}

local utils = require("utils")

local api = vim.api
local opt = vim.opt
local cmd = vim.cmd

local DEBOUNCE_MS = 100

---@type fun(): nil
local redraw_debounce, _ = utils.debounce(function() cmd.redrawstatus() end, DEBOUNCE_MS)

---Setup autocommands for statusline behavior
---Configures automatic statusline activation and refresh on various events
---@return nil
M.setup_autocommands = function()
    local group = api.nvim_create_augroup("Statusline", { clear = true })

    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function() opt.statusline = "%!v:lua.Statusline()" end,
    })

    api.nvim_create_autocmd({ "ModeChanged", "VimResized", "WinResized" }, {
        group = group,
        callback = redraw_debounce,
    })
end

return M
