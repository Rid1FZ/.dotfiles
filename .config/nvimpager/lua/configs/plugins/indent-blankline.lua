local M = {}

M.debounce = 100
M.whitespace = { highlight = { "Whitespace", "NonText" } }

M.exclude = {
    filetypes = {
        "help",
        "terminal",
        "lazy",
        "",
    },
    buftypes = { "terminal" },
}

M.scope = {
    enabled = false,
    show_start = false,
    show_end = false,
}

return M
