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

    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function()
            opt.statusline = "%!v:lua.Statusline()"
        end,
    })

    ---@type uv.uv_timer_t? result from vim.defer_fn call
    local redraw_timer = nil

    api.nvim_create_autocmd({ "ModeChanged", "VimResized", "WinResized" }, {
        group = group,
        callback = function()
            if redraw_timer then
                redraw_timer:stop()
            end

            redraw_timer = defer_fn(function()
                cmd.redrawstatus()
                redraw_timer = nil
            end, 100)
        end,
    })
end

return M
