local M = {}

local timer = vim.uv.new_timer()
local function safe_redraw()
    timer:stop()
    timer:start(
        50,
        0,
        vim.schedule_wrap(function()
            vim.cmd("redrawstatus")
        end)
    )
end

M.setup_autocommands = function()
    local api = vim.api
    local group = api.nvim_create_augroup("Statusline", { clear = true })

    -- When entering a window or buffer, activate statusline
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function()
            vim.opt_local.statusline = "%!v:lua.Statusline()"
        end,
    })

    -- Refresh diagnostics or mode change instantly, without flicker
    api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged" }, {
        group = group,
        callback = function()
            safe_redraw()
        end,
    })
end

return M
