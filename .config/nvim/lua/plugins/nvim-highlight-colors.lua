return {
    "brenoprata10/nvim-highlight-colors",
    event = "User FilePost",

    opts = function()
        return require("configs.plugins.nvim-highlight-colors")
    end,
}
