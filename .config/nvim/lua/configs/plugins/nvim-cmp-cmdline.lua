local M = {}
local cmp = require("cmp")

M.mapping = {
    ["<CR>"] = cmp.mapping(function(fallback)
        fallback()
    end, {
        "c",
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        else
            fallback()
        end
    end, {
        "c",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        else
            fallback()
        end
    end, {
        "c",
    }),
}

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
