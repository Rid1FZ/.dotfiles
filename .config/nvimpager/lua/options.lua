local M = {}

M.setup = function()
    -- Local shorthands
    local opt = vim.opt
    local opt_local = vim.opt_local

    --------------------------------------------------------------------
    -- General options
    --------------------------------------------------------------------
    opt.laststatus = 0
    opt.showtabline = 0
    opt.showmode = false
    opt.signcolumn = "yes:1"
    opt.splitbelow = true
    opt.splitright = true
    opt.termguicolors = true
    opt.timeoutlen = 400
    opt.wrap = false
    opt.pumheight = 10
    opt.clipboard = "unnamedplus"
    opt.cursorline = false
    opt.scrolloff = 99999
    opt.fillchars = { eob = " " }
    opt.ignorecase = true
    opt.smartcase = true
    opt.mouse = "a"

    --------------------------------------------------------------------
    -- Indentation
    --------------------------------------------------------------------
    opt.expandtab = true
    opt.shiftwidth = 4
    opt.smartindent = true
    opt.tabstop = 4
    opt.softtabstop = 4
    opt.number = false
    opt.relativenumber = false
    opt.ruler = false

    --------------------------------------------------------------------
    -- Short messages
    --------------------------------------------------------------------
    opt.shortmess = {
        s = true,
        c = true,
        F = true,
        W = true,
        I = true,
        l = true,
    }

    --------------------------------------------------------------------
    -- Set options after entering buffer
    --------------------------------------------------------------------
    -- These options are automatically overwritten by `nvimpager`. So set them using autocmd
    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("SetBufferOptions", { clear = true }),
        callback = function()
            opt_local.modifiable = false
            opt_local.readonly = true
        end,
    })

    --------------------------------------------------------------------
    -- Disable right-click menu
    --------------------------------------------------------------------
    vim.cmd([[aunmenu PopUp]])

    --------------------------------------------------------------------
    -- Filetype detection
    --------------------------------------------------------------------
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

    --------------------------------------------------------------------
    -- Treesitter language remaps
    --------------------------------------------------------------------
    vim.treesitter.language.register("bash", "zsh")
end

return M
