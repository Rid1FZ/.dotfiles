vim.pack.add({
    { src = "https://github.com/brenoprata10/nvim-highlight-colors" },
})

vim.api.nvim_create_autocmd("UIEnter", {
    group = vim.api.nvim_create_augroup("LoadNvimHighlightColors", { clear = true }),
    callback = function()
        vim.defer_fn(
            function() require("nvim-highlight-colors").setup(require("configs.plugins.nvim-highlight-colors")) end,
            10
        )
    end,
})
