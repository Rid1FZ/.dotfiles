local cmp = require("cmp")
return {
    window = {
        completion = cmp.config.window.bordered({
            border = { "", "", "", "", "", "", "", "" },
        }),
    },
    mapping = require("configs.nvim-cmp").mapping,
    formatting = {
        fields = { "abbr" },
    },
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
    matching = { disallow_symbol_nonprefix_matching = false },
}
