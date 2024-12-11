local M = {}

M.debounce = 100
M.whitespace = { highlight = { "Whitespace", "NonText" } }

M.exclude = {
    filetypes = {
        "help",
        "terminal",
        "lazy",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "",
    },
    buftypes = { "terminal" },
}

M.scope = {
    enabled = true,
    show_start = false,
    show_end = false,
}

return M
