vim.pack.add({
    { src = "https://github.com/lewis6991/gitsigns.nvim" },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "FilePost",
    once = true,
    callback = function() require("gitsigns").setup(require("configs.plugins.gitsigns")) end,
})
