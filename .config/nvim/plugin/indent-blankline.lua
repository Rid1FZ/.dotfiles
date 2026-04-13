vim.pack.add({
    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
})

vim.api.nvim_create_autocmd("User", {
    pattern = "FilePost",
    once = true,
    callback = function() require("ibl").setup(require("configs.plugins.indent-blankline")) end,
})
