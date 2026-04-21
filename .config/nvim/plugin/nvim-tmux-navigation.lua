vim.pack.add({
    { src = "https://github.com/alexghergh/nvim-tmux-navigation" },
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.defer_fn(function() require("nvim-tmux-navigation").setup({}) end, 10)
    end,
})
