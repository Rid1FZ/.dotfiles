return {
    "lewis6991/gitsigns.nvim",
    event = "User FilePost",

    opts = function()
        return require("configs.plugins.gitsigns")
    end,
}
