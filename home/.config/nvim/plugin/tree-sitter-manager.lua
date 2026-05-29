vim.pack.add({
    { src = "https://github.com/romus204/tree-sitter-manager.nvim" },
})

vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        vim.defer_fn(
            function() require("tree-sitter-manager").setup(require("configs.plugins.tree-sitter-manager")) end,
            10
        )
    end,
})
