return {
    "nvim-tree/nvim-web-devicons",
    event = "VimEnter",

    opts = function()
        return require("configs.nvim-web-devicons")
    end,
}
