local M = {}

M.setup_autocommands = function()
    local statusline_group = vim.api.nvim_create_augroup("Statusline", { clear = true })

    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        pattern = "*",
        group = statusline_group,
        callback = function()
            vim.opt_local.statusline = "%!v:lua.Statusline.active()"
            vim.cmd.redrawstatus()
        end,
    })

    vim.api.nvim_create_autocmd({ "ModeChanged", "DiagnosticChanged" }, {
        pattern = "*",
        group = statusline_group,
        callback = function()
            vim.cmd.redrawstatus()
        end,
    })

    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        pattern = "*",
        group = statusline_group,
        callback = function()
            vim.opt_local.statusline = "%!v:lua.Statusline.inactive()"
        end,
    })
end

return M
