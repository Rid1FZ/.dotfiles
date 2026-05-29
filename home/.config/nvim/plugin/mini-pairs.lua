vim.pack.add({
    { src = "https://github.com/nvim-mini/mini.pairs" },
})

require("utils").load_mappings("mini-pairs")
vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = function() require("mini.pairs").setup(require("configs.plugins.mini-pairs")) end,
})
