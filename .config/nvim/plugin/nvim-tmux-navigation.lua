vim.pack.add({
    { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
})

vim.defer_fn(function() require("nvim-tmux-navigation").setup({}) end, 10)
