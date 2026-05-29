vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua", name = "nvim-tree" },
})

-- `NvimTree` requires the `setup` function to be called when the plugin is being loaded.
-- Using `defer_fn` or `VimEnter` event will cause it to throw an error.
require("nvim-tree").setup(require("configs.plugins.nvim-tree"))
require("utils").load_mappings("nvim-tree")
