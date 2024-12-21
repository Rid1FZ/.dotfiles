return {
    "nvimtools/none-ls.nvim",
    event = "User FilePost",

    opts = function()
        return require("configs.plugins.none-ls")
    end,
}
