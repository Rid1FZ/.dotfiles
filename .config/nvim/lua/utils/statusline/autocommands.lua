local M = {}

function M.setup_autocommands()
    local statusline_group = vim.api.nvim_create_augroup("Statusline", { clear = true })

    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "ModeChanged", "DiagnosticChanged" }, {
        pattern = "*",
        group = statusline_group,
        callback = function()
            vim.opt_local.statusline = "%!v:lua.Statusline.active()"
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
