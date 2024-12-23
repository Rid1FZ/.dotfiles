return {
  -- snippet plugin
  "L3MON4D3/LuaSnip",

  dependencies = {
    "rafamadriz/friendly-snippets",
  },

  opts = {
    history = true,
    updateevents = "TextChanged,TextChangedI",
  },

  config = function(_, opts)
    require("configs.plugins.luasnip").setup(opts)
  end,
}
