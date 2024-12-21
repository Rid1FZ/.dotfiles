return {
    "nvimtools/none-ls.nvim",
    event = "User FilePost",

    dependencies = {
        "nvimtools/none-ls-extras.nvim",
        "nvim-lua/plenary.nvim",
    },

    opts = function()
        return require("configs.plugins.none-ls")
    end,
}
