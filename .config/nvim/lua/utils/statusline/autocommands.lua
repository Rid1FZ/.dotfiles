---@class StatuslineAutocommands
local M = {}

local api = vim.api
local opt = vim.opt
local cmd = vim.cmd
local defer_fn = vim.defer_fn

local DEBOUNCE_MS = 100

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

    ---@type uv.uv_timer_t?
    local debounce_timer = nil

    api.nvim_create_autocmd({ "ModeChanged", "VimResized", "WinResized" }, {
        group = group,
        callback = function()
            if debounce_timer then
                debounce_timer:stop()
                debounce_timer:close()
                debounce_timer = nil
            end

            debounce_timer = defer_fn(function()
                debounce_timer = nil
                cmd.redrawstatus()
            end, DEBOUNCE_MS)
        end,
    })
end

return M
