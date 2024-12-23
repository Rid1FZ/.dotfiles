return {
  "neovim/nvim-lspconfig",
  event = "User FilePost",

  config = function()
    require("configs.plugins.nvim-lspconfig")
  end,
}
