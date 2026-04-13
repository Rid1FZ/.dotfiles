vim.pack.add({
    { src = "https://github.com/echasnovski/mini.diff" },
})

require("utils").load_mappings("mini-diff")
vim.api.nvim_create_autocmd("User", {
    pattern = "FilePost",
    once = true,
    callback = function() require("mini.diff").setup(require("configs.plugins.mini-diff")) end,
})
