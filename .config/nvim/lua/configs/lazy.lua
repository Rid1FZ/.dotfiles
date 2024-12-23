local M = {}

M.defaults = { lazy = true, version = nil }
M.install = { colorscheme = { "catppuccin-mocha" } }
M.concurrency = vim.uv.available_parallelism()

M.spec = {
  { import = "plugins" },
}

M.git = {
  timeout = 300,
  url_format = "https://github.com/%s.git",
}

M.ui = {
  icons = {
    ft = "",
    lazy = "󰂠 ",
    loaded = "",
    not_loaded = "",
  },
}

M.performance = {
  rtp = {
    disabled_plugins = {
      "2html_plugin",
      "tohtml",
      "getscript",
      "getscriptPlugin",
      "gzip",
      "logipat",
      "netrw",
      "netrwPlugin",
      "netrwSettings",
      "netrwFileHandlers",
      "matchit",
      "tar",
      "tarPlugin",
      "rrhelper",
      "spellfile_plugin",
      "vimball",
      "vimballPlugin",
      "zip",
      "zipPlugin",
      "tutor",
      "rplugin",
      "syntax",
      "synmenu",
      "optwin",
      "compiler",
      "bugreport",
      "ftplugin",
    },
  },
}

return M
