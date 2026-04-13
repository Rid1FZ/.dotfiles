vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
})

vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("LoadNvimTreesitter", { clear = true }),
    callback = function() vim.cmd([[TSUpdate]]) end,
})

vim.defer_fn(function() require("nvim-treesitter").setup() end, 10)
