return {
    "folke/which-key.nvim",
    event = "VimEnter",

    opts = function()
        return require("configs.plugins.which-key")
    end,
}
