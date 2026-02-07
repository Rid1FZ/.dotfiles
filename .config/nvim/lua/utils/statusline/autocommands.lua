---@class StatuslineAutocommands
local M = {}

local api = vim.api
local opt = vim.opt
local cmd = vim.cmd
local defer_fn = vim.defer_fn

---Setup autocommands for statusline behavior
---Configures automatic statusline activation and refresh on various events
---@return nil
M.setup_autocommands = function()
    local group = api.nvim_create_augroup("Statusline", { clear = true })

    -- When entering a window or buffer, activate statusline
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function()
            opt.statusline = "%!v:lua.Statusline()"
        end,
    })

    -- Refresh  instantly, without flicker
    api.nvim_create_autocmd({ "ModeChanged", "VimResized", "WinResized" }, {
        group = group,
        callback = function()
            defer_fn(function()
                cmd.redrawstatus()
            end, 10)
        end,
    })
end

return M
