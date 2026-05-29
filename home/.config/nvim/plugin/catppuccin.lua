vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup(require("configs.plugins.catppuccin"))

vim.cmd.colorscheme("catppuccin-nvim")
