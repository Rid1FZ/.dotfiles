vim.pack.add({
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
})

vim.defer_fn(function() require("ibl").setup(require("configs.plugins.indent-blankline")) end, 10)
