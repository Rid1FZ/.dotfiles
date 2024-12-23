return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeOpen" },

  init = function()
    require("utils").load_mappings("nvimtree")
  end,

  opts = function()
    return require("configs.plugins.nvim-tree")
  end,
}
