local M = {}

M.flavour = "mocha"
M.background = {
    light = "latte",
    dark = "mocha",
}
M.transparent_background = false
M.float = {
    transparent = false,
    solid = false,
}
M.no_italic = false
M.no_bold = false
M.no_underline = false
M.styles = {
    comments = { "italic" },
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
}
M.lsp_styles = {
    virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
        ok = { "italic" },
    },
    underlines = {
        errors = { "underline" },
        hints = { "underline" },
        warnings = { "underline" },
        information = { "underline" },
        ok = { "underline" },
    },
    inlay_hints = {
        background = true,
    },
}
M.default_integrations = true
M.auto_integrations = false
M.integrations = {
    nvimtree = true,
    mini = {
        enabled = true,
        indentscope_color = "",
    },
}
return M
