local M = {}

local keymap = vim.keymap

M.disable_netrw = true
M.hijack_netrw = true
M.hijack_cursor = true
M.hijack_unnamed_buffer_when_opening = false
M.sync_root_with_cwd = true

M.on_attach = function(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
        return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
        }
    end

    -- Fileops
    keymap.set("n", "a", api.fs.create, opts("Create File Or Directory"))
    keymap.set("n", "d", api.fs.trash, opts("Trash"))
    keymap.set("n", "D", api.marks.bulk.trash, opts("Trash Marked"))
    keymap.set("n", "p", api.fs.paste, opts("Paste"))
    keymap.set("n", "y", api.fs.copy.node, opts("Copy"))
    keymap.set("n", "C", api.fs.copy.absolute_path, opts("Copy Absolute Path"))
    keymap.set("n", "c", api.fs.copy.basename, opts("Copy Basename"))
    keymap.set("n", "x", api.fs.cut, opts("Cut"))
    keymap.set("n", "r", api.fs.rename, opts("Rename"))
    keymap.set("n", "<C-r>", api.fs.rename_full, opts("Rename: Full Path"))

    -- Navigation
    keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
    keymap.set("n", "o", api.node.open.edit, opts("Open"))
    keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
    keymap.set("n", "O", api.node.open.no_window_picker, opts("Open: No Window Picker"))
    keymap.set("n", "<Tab>", api.node.open.preview, opts("Open Preview"))
    keymap.set("n", "<2-RightMouse>", api.tree.change_root_to_node, opts("CD"))

    -- Others
    keymap.set("n", "<Space>", api.marks.toggle, opts("Toggle Bookmark"))
    keymap.set("n", "q", api.tree.close, opts("Close"))
    keymap.set("n", "R", api.tree.reload, opts("Refresh"))
    keymap.set("n", "<S-k>", api.node.show_info_popup, opts("Info"))
    keymap.set("n", ".", api.node.run.cmd, opts("Run Command"))
    keymap.set("n", "-", api.tree.change_root_to_parent, opts("Up"))
    keymap.set("n", "g?", api.tree.toggle_help, opts("Help"))
    keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("Toggle Filter: Dotfiles"))
    keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("Toggle Filter: Git Ignore"))
    keymap.set("n", "<Esc>", api.live_filter.clear, opts("Live Filter: Clear"))
    keymap.set("n", "/", api.live_filter.start, opts("Live Filter: Start"))
end

M.filters = {
    dotfiles = false,
    custom = {
        [[^\.git$]],
        [[^\.null-ls.*]],
        [[^__pycache__$]],
        [[^.mypy_cache$]],
    },
}

M.live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = false,
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
    file_popup = {
        open_win_config = {
            col = 1,
            row = 1,
            relative = "cursor",
            border = "rounded",
            style = "minimal",
        },
    },
}

M.trash = {
    cmd = "trash-put",
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
