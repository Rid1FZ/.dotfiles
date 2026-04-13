vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = vim.api.nvim_create_augroup("LoadNvimAutopairs", { clear = true }),
    callback = function()
        vim.defer_fn(function() require("nvim-autopairs").setup(require("configs.plugins.nvim-autopairs")) end, 10)
    end,
})
