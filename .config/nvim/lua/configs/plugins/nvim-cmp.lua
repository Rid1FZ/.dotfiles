local M = {}
local cmp = require("cmp")

local border_chars = {
    "╭",
    "─",
    "╮",
    "│",
    "╯",
    "─",
    "╰",
    "│",
}

M.preselect = cmp.PreselectMode.None

M.completion = {
    completeopt = "menu,menuone,noselect",
}

M.window = {
    completion = cmp.config.window.bordered({
        border = border_chars,
        scrollbar = true,
    }),
    documentation = cmp.config.window.bordered({
        border = border_chars,
        max_height = 5,
        max_width = 60,
    }),
}

M.snippet = {
    expand = function(args)
        require("luasnip").lsp_expand(args.body)
    end,
}

M.formatting = {
    -- default fields order i.e completion word + item.kind + item.kind icons
    fields = { "kind", "abbr" },

    format = function(_, item)
        local icons = require("configs.lspkind-icons")
        local icon = icons[item.kind]

        item.kind = string.format("%s", icon)

        return item
    end,
}

M.mapping = {
    ["<C-p>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end, {
        "i",
    }),

    ["<C-n>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end, {
        "i",
    }),

    ["<Esc>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.close()
        else
            fallback()
        end
    end, {
        "i",
    }),

    ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
            fallback()
        end
    end, {
        "i",
    }),

    ["<Tab>"] = cmp.mapping(function(fallback)
        if require("luasnip").expand_or_jumpable() then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
        elseif cmp.visible() then
            cmp.select_next_item()
        else
            fallback()
        end
    end, {
        "i",
    }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
        if require("luasnip").jumpable(-1) then
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
        elseif cmp.visible() then
            cmp.select_prev_item()
        else
            fallback()
        end
    end, {
        "i",
    }),
}

M.sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "lazydev" },
    { name = "luasnip" },
    { name = "buffer" },
    { name = "nvim_lua" },
    { name = "path" },
})

return M
