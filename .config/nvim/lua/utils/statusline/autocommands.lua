local M = {}

M.setup_autocommands = function()
    local api = vim.api
    local opt = vim.opt
    local group = api.nvim_create_augroup("Statusline", { clear = true })

    -- When entering a window or buffer, activate statusline
    api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        group = group,
        callback = function()
            opt.statusline = "%!v:lua.Statusline()"
        end,
    })

    -- Refresh diagnostics or mode change instantly, without flicker
    api.nvim_create_autocmd({ "ModeChanged" }, {
        group = group,
        callback = function()
            vim.defer_fn(function()
                vim.cmd("redrawstatus")
            end, 10)
        end,
    })
end

return M
