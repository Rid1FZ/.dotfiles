local M = {}

M.preset = "classic"
M.notify = true
M.sort = { "local", "order", "group", "alphanum", "mod" }
M.expand = 0
M.show_help = true
M.show_keys = true

M.delay = function(ctx)
    return ctx.plugin and 0 or 200
end

M.spec = {
    {
        mode = { "n", "v" },
        { "<Leader>b", group = "Buffer" },
        { "<Leader>f", group = "Find" },
        { "<Leader>g", group = "Git" },
        { "<Leader>l", group = "LSP" },
        { "<Leader>o", group = "Open" },
        { "<Leader>w", group = "Window" },
    },
}

M.plugins = {
    marks = true,
    registers = true,
    spelling = {
        enabled = false,
    },
    presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
    },
}

M.win = {
    no_overlap = true,
    padding = { 2, 3 },
    title = true,
    title_pos = "center",
    zindex = 1000,
    -- Additional vim.wo and vim.bo options
    bo = {},
    wo = {
        winblend = 0,
    },
}

M.layout = {
    width = { min = 20 },
    height = { min = 5 },
    spacing = 3,
}

M.keys = {
    scroll_down = "<c-d>", -- binding to scroll down inside the popup
    scroll_up = "<c-u>", -- binding to scroll up inside the popup
}

M.replace = {
    key = {
        function(key)
            return require("which-key.view").format(key)
        end,
    },
    desc = {
        { "<Plug>%(?(.*)%)?", "%1" },
        { "^%+", "" },
        { "<[cC]md>", "" },
        { "<[cC][rR]>", "" },
        { "<[sS]ilent>", "" },
        { "^lua%s+", "" },
        { "^call%s+", "" },
        { "^:%s*", "" },
    },
}

M.icons = {
    breadcrumb = " ",
    separator = " ", -- symbol used between a key and it's label
    group = " ", -- symbol prepended to a group
    ellipsis = "󰇘",
    mappings = false,
    rules = {},
    colors = true,
    keys = {
        Up = " ",
        Down = " ",
        Left = " ",
        Right = " ",
        C = "󰘴 ",
        M = "󰘵 ",
        D = "󰘳 ",
        S = "󰘶 ",
        CR = "󰌑 ",
        Esc = "󱊷 ",
        ScrollWheelDown = "󱕐 ",
        ScrollWheelUp = "󱕑 ",
        NL = "󰌑 ",
        BS = "󰁮",
        Space = "󱁐 ",
        Tab = "󰌒 ",
        F1 = "󱊫",
        F2 = "󱊬",
        F3 = "󱊭",
        F4 = "󱊮",
        F5 = "󱊯",
        F6 = "󱊰",
        F7 = "󱊱",
        F8 = "󱊲",
        F9 = "󱊳",
        F10 = "󱊴",
        F11 = "󱊵",
        F12 = "󱊶",
    },
}

M.disable = {
    ft = {
        "NvimTree",
    },
    bt = {},
}

return M
