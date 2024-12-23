local M = {}

M.extensions = {
  ["ui-select"] = {
    require("telescope.themes").get_dropdown({}),
  },
  ["fzf"] = {
    fuzzy = true, -- false will only do exact matching
    override_generic_sorter = true, -- override the generic sorter
    override_file_sorter = true, -- override the file sorter
    case_mode = "smart_case", -- or "ignore_case" or "respect_case"
  },
}

M.defaults = {
  vimgrep_arguments = {
    "rg",
    "--no-config",
    "--hidden",
    "--follow",
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
  },
  prompt_prefix = "   ",
  selection_caret = "  ",
  entry_prefix = "  ",
  initial_mode = "insert",
  selection_strategy = "reset",
  sorting_strategy = "ascending",
  layout_strategy = "horizontal",
  layout_config = {
    horizontal = {
      prompt_position = "top",
      preview_width = 0.55,
    },
    vertical = {
      mirror = false,
    },
    width = 0.90,
    height = 0.80,
    preview_cutoff = 120,
  },
  file_sorter = require("telescope.sorters").get_fuzzy_file,
  file_ignore_patterns = { "node_modules" },
  generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
  pickers = {
    live_grep = {
      only_sort_text = true,
    },
  },
  path_display = { "truncate" },
  winblend = 0,
  border = true,
  borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  color_devicons = true,
  set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
  file_previewer = require("telescope.previewers").vim_buffer_cat.new,
  grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
  qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
  buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  mappings = {
    n = { ["q"] = require("telescope.actions").close },
  },
}

return M
