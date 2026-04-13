vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-tree.lua", name = "nvim-tree" },
})

require("nvim-tree").setup(require("configs.plugins.nvim-tree"))
require("utils").load_mappings("nvim-tree")
