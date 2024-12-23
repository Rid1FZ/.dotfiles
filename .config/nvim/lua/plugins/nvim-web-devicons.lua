return {
  "nvim-tree/nvim-web-devicons",
  event = "VimEnter",

  opts = function()
    return require("configs.plugins.nvim-web-devicons")
  end,
}
