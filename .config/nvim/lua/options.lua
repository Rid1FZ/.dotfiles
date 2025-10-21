local M = {}

local opt = {}
local g = {}
local filetypes = {}
local treesitter_langs = {}

g.mapleader = " "
g.neovide_cursor_animation_length = 0
g.neovide_scroll_animation_length = 0

opt.title = true
opt.laststatus = 3
opt.showtabline = 0
opt.showmode = false

opt.clipboard = "unnamedplus"
opt.cursorline = true

opt.completeopt = {
    "fuzzy",
    "menu",
    "menuone",
    "noselect",
    "preview",
}

-- Indenting
opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = true
opt.relativenumber = true
opt.numberwidth = 3
opt.ruler = false
opt.shortmess = {
    s = true,
    c = true,
    F = true,
    W = true,
    I = true,
    l = true,
}

opt.signcolumn = "yes:1"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.undofile = true
opt.wrap = false
opt.confirm = true
opt.swapfile = false
opt.pumheight = 10

-- Interval for Writing Swap File to Disk
opt.updatetime = 250

-- Disable Right Click Menu
vim.cmd([[aunmenu PopUp]])

-- Add Binaries Installed by mason.nvim to PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Add Filetypes
filetypes.extension = {
    qml = "qml",
    ipy = "python",
    sh = "bash",
    bash = "bash",
}

filetypes.pattern = {
    ["/home/.*/.config/hypr/.*.conf"] = "hyprlang",
    [".*/hyperland/.*.conf"] = "hyprlang",
    ["/home/.*/.config/waybar/config"] = "jsonc",
    ["/home/.*/.config/zathura/.*"] = "zathurarc",
    ["/home/.*/.config/tmux/configs/.*.tmux"] = "tmux",
}

-- register grammers
treesitter_langs["bash"] = "zsh"

M.setup = function()
    -- Set global variables first
    for global_var, value in pairs(g) do
        vim.g[global_var] = value
    end

    -- Set options
    for option, value in pairs(opt) do
        vim.opt[option] = value
    end

    -- Set filetypes
    vim.filetype.add(filetypes)

    -- Register treesitter grammers
    for lang, filetype in pairs(treesitter_langs) do
        vim.treesitter.language.register(lang, filetype)
    end
end

return M
