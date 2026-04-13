vim.pack.add({
    { src = "https://github.com/windwp/nvim-autopairs" },
})

require("utils").load_mappings("nvim-autopairs")
vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = function() require("nvim-autopairs").setup(require("configs.plugins.nvim-autopairs")) end,
})
