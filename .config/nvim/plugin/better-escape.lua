vim.pack.add({
    { src = "https://github.com/max397574/better-escape.nvim" },
})

vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = function() require("better_escape").setup(require("configs.plugins.better-escape")) end,
})
