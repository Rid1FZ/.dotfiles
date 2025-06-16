local M = {}

M.cmdline = {
    enabled = true,
}

M.cmdline.completion = {
    list = {
        selection = {
            preselect = false,
            auto_insert = true,
        },
    },
    menu = {
        auto_show = false,
        draw = {
            columns = {
                { "label" },
            },
        },
    },
}

M.cmdline.keymap = {
    preset = "none",
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<Tab>"] = { "show_and_insert", "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
    ["<CR>"] = { "accept_and_enter", "fallback" },
}

M.completion = {
    list = {
        selection = {
            preselect = false,
            auto_insert = true,
        },
    },
    menu = {
        auto_show = true,

        draw = {
            columns = {
                { "kind_icon" },
                { "label" },
            },
            padding = { 1, 1 },
            components = {
                kind_icon = {
                    text = function(ctx)
                        return ctx.kind_icon .. "  " .. ctx.icon_gap
                    end,
                },
            },
        },
    },
    documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
    },
}

M.sources = {
    default = { "lsp", "snippets", "path", "buffer" },
}

M.signature = {
    enabled = false,

    window = {
        show_documentation = false,
        border = "rounded",
    },
}

M.fuzzy = {
    implementation = "rust",
}

M.keymap = {
    preset = "none",
    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
    ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    ["<CR>"] = { "accept", "fallback" },
}

return M
