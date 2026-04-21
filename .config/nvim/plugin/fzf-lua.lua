vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
})

-- Using `VimEnter` will cause the configs to not load when using `nvim DIR`
vim.defer_fn(function()
    require("utils").load_mappings("fzf-lua")
    require("fzf-lua").setup(require("configs.plugins.fzf-lua"))
end, 10)
