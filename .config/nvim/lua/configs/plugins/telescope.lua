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
    file_sorter = require("telescope.sorters").get_fuzzy_file,
    file_ignore_patterns = { "node_modules" },
    generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
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
    prompt_prefix = "   ",
    selection_caret = "  ",
    entry_prefix = "  ",
    initial_mode = "insert",
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
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
    mappings = {
        i = {
            ["<Esc>"] = require("telescope.actions").close,
        },
        n = {
            ["q"] = require("telescope.actions").close,
        },
    },
}

M.pickers = {
    buffers = {
        theme = "dropdown",
        sort_lastused = true,
        sort_mru = true,
        select_current = false,
    },

    find_files = {
        theme = "dropdown",
        follow = true,
        hidden = true,
    },

    oldfiles = {
        theme = "dropdown",
    },

    live_grep = {
        theme = "dropdown",
    },

    help_tags = {
        theme = "dropdown",
    },
}

return M
