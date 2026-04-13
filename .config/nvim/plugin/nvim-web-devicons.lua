vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("LoadWebDevicons", { clear = true }),
    callback = function()
        vim.defer_fn(
            function() require("nvim-web-devicons").setup(require("configs.plugins.nvim-web-devicons")) end,
            10
        )
    end,
})
