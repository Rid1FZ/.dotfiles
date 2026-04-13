vim.pack.add({
    { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "FilePost",
    once = true,
    callback = function() require("nvim-highlight-colors").setup(require("configs.plugins.nvim-highlight-colors")) end,
})
