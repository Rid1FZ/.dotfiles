return {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    keys = { ":" },

    opts = function()
        return require("configs.plugins.blink-cmp")
    end,
}
