local M = {}

M.filetypes = { "*" }
M.user_commands = true

M.user_default_options = {
    RGB = false, -- #RGB hex code
    RRGGBB = true, -- #RRGGBB hex code
    names = false,
    RRGGBBAA = false,
    AARRGGBB = false,
    rgb_fn = true,
    hsl_fn = true,
    css = false,
    css_fn = false,
    mode = "background",
    always_update = false,
}

return M
