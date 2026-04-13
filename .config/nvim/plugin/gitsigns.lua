vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

vim.defer_fn(function() require("gitsigns").setup(require("configs.plugins.gitsigns")) end, 10)
