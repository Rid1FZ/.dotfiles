local M = {}

M.PATH = "skip"
M.max_concurrent_installers = vim.uv.available_parallelism()

M.ui = {
    icons = {
        package_pending = " ",
        package_installed = "󰄳 ",
        package_uninstalled = " 󰚌",
    },
}

return M
