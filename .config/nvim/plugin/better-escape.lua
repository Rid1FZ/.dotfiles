vim.pack.add({
    { src = "https://github.com/max397574/better-escape.nvim" },
})

vim.defer_fn(function() require("better_escape").setup(require("configs.plugins.better-escape")) end, 10)
