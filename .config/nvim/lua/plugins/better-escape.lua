return {
    "max397574/better-escape.nvim",
    event = "User FilePost",

    opts = function()
        return require("configs.better-escape")
    end,
}
