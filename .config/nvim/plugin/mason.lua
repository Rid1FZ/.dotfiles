vim.pack.add({
    { src = "https://github.com/williamboman/mason.nvim" },
})

vim.defer_fn(function() require("mason").setup(require("configs.plugins.mason")) end, 1000)
