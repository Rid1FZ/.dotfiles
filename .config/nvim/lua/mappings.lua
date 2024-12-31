-- n, v, i, t = mode names
-- group names are defined in configs.which-key

local M = {}

local tbuiltin = require("telescope.builtin")
local nvim_tree = require("nvim-tree.api").tree
local gitsigns = require("gitsigns")
local floattui = require("utils.floattui")
local floatterminal = require("utils.floattui.terminal")

M.general = {
    i = {},

    n = {
        ["<Esc>"] = { "<cmd> noh <CR>", "Clear highlights" },

        ["<C-h>"] = { "<Cmd>NvimTmuxNavigateLeft<CR>", "Window left" },
        ["<C-l>"] = { "<Cmd>NvimTmuxNavigateRight<CR>", "Window right" },
        ["<C-k>"] = { "<Cmd>NvimTmuxNavigateUp<CR>", "Window up" },
        ["<C-j>"] = { "<Cmd>NvimTmuxNavigateDown<CR>", "Window down" },

        -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
        -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
        -- empty mode is same as using <cmd> :map
        -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
        ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
        ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
        ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
        ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },

        ["<Leader>oh"] = {
            function()
                vim.schedule(function()
                    floattui.open("htop")
                end)
            end,
            "Open htop",
        },

        ["<Leader>ol"] = {
            function()
                vim.schedule(function()
                    floattui.open("lazygit")
                end)
            end,
            "Open lazygit",
        },

        ["<Leader>ot"] = {
            function()
                vim.schedule(function()
                    floatterminal.open()
                end)
            end,
            "Open terminal",
        },
    },

    t = {},

    v = {
        ["<Up>"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
        ["<Down>"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
        ["<"] = { "<gv", "Indent line" },
        [">"] = { ">gv", "Indent line" },
    },

    x = {
        ["j"] = { 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', "Move down", opts = { expr = true } },
        ["k"] = { 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', "Move up", opts = { expr = true } },
        -- Don't copy the replaced text after pasting in visual mode
        -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
        ["p"] = { 'p:let @+=@0<CR>:let @"=@0<CR>', "Dont copy replaced text", opts = { silent = true } },
    },
}

M.lspconfig = {
    plugin = true,
    n = {
        ["gD"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.declaration()
                end)
            end,
            "LSP declaration",
        },

        ["gd"] = {
            function()
                vim.schedule(function()
                    tbuiltin.lsp_definitions()
                end)
            end,
            "LSP definition",
        },

        ["K"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.hover()
                end)
            end,
            "LSP hover",
        },

        ["gi"] = {
            function()
                vim.schedule(function()
                    tbuiltin.lsp_implementations()
                end)
            end,
            "LSP implementation",
        },

        ["<leader>ls"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.signature_help()
                end)
            end,
            "LSP signature help",
        },

        ["<leader>lf"] = {
            function()
                local providers = {
                    "null-ls",
                }
                vim.schedule(function()
                    vim.lsp.buf.format({
                        async = false,
                        timeout_ms = 5000,
                        filter = function(client)
                            for _, provider in ipairs(providers) do
                                if client.name == provider then
                                    print(client.name)
                                    return true
                                end
                            end
                            return false
                        end,
                    })
                end)
            end,
            "LSP formatting",
        },

        ["<leader>lD"] = {
            function()
                vim.schedule(function()
                    tbuiltin.diagnostics()
                end)
            end,
            "LSP list all diagnostics",
        },

        ["<leader>lr"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.rename()
                end)
            end,
            "LSP rename",
        },

        ["<leader>la"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.code_action()
                end)
            end,
            "LSP code action",
        },

        ["gr"] = {
            function()
                vim.schedule(function()
                    tbuiltin.lsp_references()
                end)
            end,
            "LSP references",
        },

        ["<leader>ld"] = {
            function()
                vim.schedule(function()
                    vim.diagnostic.open_float({
                        border = "rounded",
                        scope = "cursor",
                        severity_sort = true,
                    })
                end)
            end,
            "Floating diagnostic",
        },

        ["[d"] = {
            function()
                vim.schedule(function()
                    vim.diagnostic.goto_prev({ float = { border = "rounded" } })
                end)
            end,
            "Goto prev",
        },

        ["]d"] = {
            function()
                vim.schedule(function()
                    vim.diagnostic.goto_next({ float = { border = "rounded" } })
                end)
            end,
            "Goto next",
        },

        ["<leader>q"] = {
            function()
                vim.schedule(function()
                    vim.diagnostic.setloclist()
                end)
            end,
            "Diagnostic setloclist",
        },
    },

    v = {
        ["<leader>la"] = {
            function()
                vim.schedule(function()
                    vim.lsp.buf.code_action()
                end)
            end,
            "LSP code action",
        },
    },
}

M.nvimtree = {
    plugin = true,

    n = {
        -- focus
        ["<leader>oe"] = {
            function()
                vim.schedule(function()
                    nvim_tree.focus()
                end)
            end,
            "Focus explorer",
        },
    },
}

M.telescope = {
    plugin = true,

    n = {
        -- find
        ["<leader>ff"] = {
            function()
                vim.schedule(function()
                    tbuiltin.find_files()
                end)
            end,
            "Find files",
        },

        ["<leader>fa"] = {
            function()
                vim.schedule(function()
                    tbuiltin.find_files({
                        no_ignore = true,
                    })
                end)
            end,
            "Find all files",
        },

        ["<leader>fw"] = {
            function()
                vim.schedule(function()
                    tbuiltin.live_grep()
                end)
            end,
            "Live grep",
        },

        ["<leader>fb"] = {
            function()
                vim.schedule(function()
                    tbuiltin.buffers()
                end)
            end,
            "Find buffers",
        },

        ["<leader>fh"] = {
            function()
                vim.schedule(function()
                    tbuiltin.help_tags()
                end)
            end,
            "Help page",
        },

        ["<leader>fo"] = {
            function()
                vim.schedule(function()
                    tbuiltin.oldfiles()
                end)
            end,
            "Find oldfiles",
        },
    },
}

M.gitsigns = {
    plugin = true,

    n = {
        -- Navigation through hunks
        ["]c"] = {
            function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(function()
                    gitsigns.next_hunk()
                end)
                return "<Ignore>"
            end,
            "Jump to next hunk",
            opts = { expr = true },
        },

        ["[c"] = {
            function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(function()
                    gitsigns.prev_hunk()
                end)
                return "<Ignore>"
            end,
            "Jump to prev hunk",
            opts = { expr = true },
        },

        -- Actions
        ["<leader>gr"] = {
            function()
                vim.schedule(function()
                    gitsigns.reset_hunk()
                end)
            end,
            "Reset hunk",
        },

        ["<leader>gp"] = {
            function()
                vim.schedule(function()
                    gitsigns.preview_hunk()
                end)
            end,
            "Preview hunk",
        },

        ["<leader>gb"] = {
            function()
                vim.schedule(function()
                    gitsigns.blame_line()
                end)
            end,
            "Blame line",
        },

        ["<leader>gt"] = {
            function()
                vim.schedule(function()
                    gitsigns.toggle_deleted()
                end)
            end,
            "Toggle deleted",
        },

        ["<leader>gm"] = {
            function()
                vim.schedule(function()
                    tbuiltin.git_commits()
                end)
            end,
            "Git commits",
        },

        ["<leader>gs"] = {
            function()
                vim.schedule(function()
                    tbuiltin.git_status()
                end)
            end,
            "Git status",
        },
    },
}

return M
