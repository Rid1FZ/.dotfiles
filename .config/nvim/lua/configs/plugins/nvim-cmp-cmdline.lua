local M = {}
local cmp = require("cmp")

M.mapping = require("configs.plugins.nvim-cmp").mapping

M.matching = {
    disallow_symbol_nonprefix_matching = false,
}

M.window = {
    completion = cmp.config.window.bordered({
        border = { "", "", "", "", "", "", "", "" },
    }),
}

M.formatting = {
    fields = { "abbr" },
}

M.sources = cmp.config.sources({
    { name = "path" },
    { name = "cmdline" },
})

return M
