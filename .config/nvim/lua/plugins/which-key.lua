return {
    "folke/which-key.nvim",
    event = "VimEnter",

    opts = function()
        return require("configs.which-key")
    end,
}
