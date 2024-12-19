return {
    "max397574/better-escape.nvim",
    event = "InsertEnter",

    opts = function()
        return require("configs.better-escape")
    end,
}
