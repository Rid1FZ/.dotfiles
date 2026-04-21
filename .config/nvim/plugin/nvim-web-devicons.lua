vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function() require("nvim-web-devicons").setup(require("configs.plugins.nvim-web-devicons")) end,
})
