local M = {}

M.setup = function()
    -- Local shorthand
    local opt = vim.opt
    local g = vim.g
    local env = vim.env

    --------------------------------------------------------------------
    -- Global variables
    --------------------------------------------------------------------
    g.mapleader = " "
    g.neovide_cursor_animation_length = 0
    g.neovide_scroll_animation_length = 0

    --------------------------------------------------------------------
    -- General options
    --------------------------------------------------------------------
    opt.title = true
    opt.laststatus = 3
    opt.showtabline = 0
    opt.showmode = false
    opt.clipboard = "unnamedplus"
    opt.cursorline = true
    opt.termguicolors = true
    opt.confirm = true
    opt.wrap = false
    opt.swapfile = false
    opt.undofile = true
    opt.timeoutlen = 400
    opt.updatetime = 250
    opt.mouse = "a"
    opt.signcolumn = "yes:1"
    opt.splitbelow = true
    opt.splitright = true
    opt.number = true
    opt.relativenumber = true
    opt.numberwidth = 3
    opt.ruler = false
    opt.pumheight = 10
    opt.ignorecase = true
    opt.smartcase = true
    opt.fillchars:append({ eob = " " })

    --------------------------------------------------------------------
    -- Completion behavior
    --------------------------------------------------------------------
    opt.completeopt = { "fuzzy", "menu", "menuone", "noselect" }

    --------------------------------------------------------------------
    -- Indentation
    --------------------------------------------------------------------
    opt.expandtab = true
    opt.shiftwidth = 4
    opt.smartindent = true
    opt.tabstop = 4
    opt.softtabstop = 4

    --------------------------------------------------------------------
    -- Short messages
    --------------------------------------------------------------------
    opt.shortmess:append({
        s = true,
        c = true,
        F = true,
        W = true,
        I = true,
        l = true,
    })

    --------------------------------------------------------------------
    -- Disable right-click menu
    --------------------------------------------------------------------
    vim.cmd("aunmenu PopUp")

    --------------------------------------------------------------------
    -- Environment setup
    --------------------------------------------------------------------
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    if not env.PATH:find(vim.pesc(mason_bin), 1, true) then
        env.PATH = mason_bin .. ":" .. env.PATH
    end

    --------------------------------------------------------------------
    -- Filetype detection
    --------------------------------------------------------------------
    vim.filetype.add({
        extension = {
            qml = "qml",
            ipy = "python",
            sh = "bash",
            bash = "bash",
            tmux = "tmux",
        },
        pattern = {
            [vim.fn.expand("$HOME") .. "/.config/hypr/.*%.conf"] = "hyprlang",
            [vim.fn.expand("$HOME") .. "/.config/waybar/config"] = "jsonc",
            [vim.fn.expand("$HOME") .. "/.config/zathura/.*"] = "zathurarc",
        },
    })
end

return M
