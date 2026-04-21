vim.pack.add({
    { src = "https://github.com/williamboman/mason.nvim" },
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.defer_fn(function() require("mason").setup(require("configs.plugins.mason")) end, 1000)
    end,
})
