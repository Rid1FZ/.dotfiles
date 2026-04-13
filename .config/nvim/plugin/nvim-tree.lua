vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua" },
})

require("utils").load_mappings("nvim-tree")
require("nvim-tree").setup(require("configs.plugins.nvim-tree"))
