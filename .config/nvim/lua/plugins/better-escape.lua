return {
    "max397574/better-escape.nvim",
    event = "InsertEnter",

    opts = function()
        return require("configs.plugins.better-escape")
    end,
}
