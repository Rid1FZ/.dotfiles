local lsp = require("configs.lsp")
local server_configs = {}
local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.neovide_cursor_animation_length = 0
g.neovide_scroll_animation_length = 0

opt.title = true
opt.laststatus = 3
opt.showtabline = 0
opt.showmode = false

opt.clipboard = "unnamedplus"
opt.cursorline = true

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
vim.filetype.add({
    extension = {
        qml = "qml",
        ipy = "python",
        sh = "bash",
        bash = "bash",
    },
    pattern = {
        ["/home/.*/.config/hypr/.*.conf"] = "hyprlang",
        [".*/hyperland/.*.conf"] = "hyprlang",
        ["/home/.*/.config/waybar/config"] = "jsonc",
        ["/home/.*/.config/zathura/.*"] = "zathurarc",
        ["/home/.*/.config/tmux/configs/.*.tmux"] = "tmux",
    },
})

-- register grammers
vim.treesitter.language.register("bash", "zsh")

-- enable lsp servers listed in `lsp` directory
for _, v in ipairs(vim.api.nvim_get_runtime_file("lsp/*", true)) do
    local name = vim.fn.fnamemodify(v, ":t:r")
    server_configs[name] = true
end

vim.lsp.enable(vim.tbl_keys(server_configs))
