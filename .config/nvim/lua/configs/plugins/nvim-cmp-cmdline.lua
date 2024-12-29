local M = {}
local cmp = require("cmp")

M.completion = {
    completeopt = "menu,menuone,noselect",
}

M.mapping = {
    ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end, {
        "c",
    }),

    ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end, {
        "c",
    }),

    ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
            fallback()
        end
    end, {
        "c",
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
        else
            fallback()
        end
    end, {
        "c",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
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
