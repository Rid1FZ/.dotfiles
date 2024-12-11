local M = {}

M.disable_netrw = true
M.hijack_netrw = true
M.hijack_cursor = true
M.hijack_unnamed_buffer_when_opening = false
M.sync_root_with_cwd = true

M.filters = {
    dotfiles = false,
    custom = {
        [[^\.git$]],
        [[^\.null-ls.*]],
        [[^__pycache__$]],
        [[^.mypy_cache$]],
    },
}

M.hijack_directories = {
    enable = false,
    auto_open = false,
}

M.update_focused_file = {
    enable = true,
    update_root = false,
}

M.view = {
    adaptive_size = false,
    side = "left",
    width = 30,
    preserve_window_proportions = true,
}

M.git = {
    enable = true,
    ignore = true,
}

M.filesystem_watchers = {
    enable = true,
}

M.actions = {
    open_file = {
        resize_window = true,
    },
}

M.renderer = {
    root_folder_label = false,
    highlight_git = false,
    highlight_opened_files = "none",
    symlink_destination = false,

    indent_markers = {
        enable = true,
    },

    icons = {
        symlink_arrow = " ",
        git_placement = "after",
        show = {
            file = true,
            folder = true,
            folder_arrow = false,
            git = true,
        },
        web_devicons = {
            file = {
                enable = true,
                color = true,
            },
            folder = {
                enable = false,
                color = true,
            },
        },
        glyphs = {
            default = "",
            symlink = "",
            folder = {
                default = "",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
                symlink_open = "",
                arrow_open = "",
                arrow_closed = "",
            },
            git = {
                unstaged = "",
                staged = "",
                unmerged = "",
                renamed = "",
                untracked = "",
                deleted = "",
                ignored = "",
            },
        },
    },
}

return M
