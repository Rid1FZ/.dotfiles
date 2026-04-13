vim.pack.add({
    { src = "https://github.com/ibhagwan/fzf-lua" },
})

require("utils").load_mappings("fzf-lua")
vim.defer_fn(function() require("fzf-lua").setup(require("configs.plugins.fzf-lua")) end, 10)
