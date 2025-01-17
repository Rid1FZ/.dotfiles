return {
    "Rid1FZ/breadcrumb.nvim",
    dependecies = {
        "nvim-tree/nvim-web-devicons",
    },

    opts = function()
        return require("configs.plugins.breadcrumb")
    end,
}
