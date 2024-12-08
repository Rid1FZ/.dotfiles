return {
    PATH = "skip",
    ui = {
        icons = {
            package_pending = " ",
            package_installed = "󰄳 ",
            package_uninstalled = " 󰚌",
        },
    },
    max_concurrent_installers = vim.uv.available_parallelism(),
}
