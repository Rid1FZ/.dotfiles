-- n, v, i, t = mode names
-- group names are defined in configs.which-key

local M = {}

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

        ["<Leader>ol"] = {
            function()
                require("utils.floattui").open("lazygit")
            end,
            "Open Lazygit",
        },
        ["<Leader>oh"] = {
            function()
                require("utils.floattui").open("htop")
            end,
            "Open Htop",
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
                vim.lsp.buf.declaration()
            end,
            "LSP declaration",
        },

        ["gd"] = {
            function()
                require("telescope.builtin").lsp_definitions()
            end,
            "LSP definition",
        },

        ["K"] = {
            function()
                vim.lsp.buf.hover()
            end,
            "LSP hover",
        },

        ["gi"] = {
            function()
                require("telescope.builtin").lsp_implementations()
            end,
            "LSP implementation",
        },

        ["<leader>ls"] = {
            function()
                vim.lsp.buf.signature_help()
            end,
            "LSP signature help",
        },

        ["<leader>lf"] = {
            function()
                local providers = {
                    "null-ls",
                }
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
            end,
            "LSP formatting",
        },

        ["<leader>lD"] = {
            function()
                require("telescope.builtin").diagnostics()
            end,
            "LSP list all diagnostics",
        },

        ["<leader>lr"] = {
            function()
                require("utils.renamer").open()
            end,
            "LSP rename",
        },

        ["<leader>la"] = {
            function()
                vim.lsp.buf.code_action()
            end,
            "LSP code action",
        },

        ["gr"] = {
            function()
                require("telescope.builtin").lsp_references()
            end,
            "LSP references",
        },

        ["<leader>ld"] = {
            function()
                vim.diagnostic.open_float({
                    border = "rounded",
                    scope = "cursor",
                    severity_sort = true,
                })
            end,
            "Floating diagnostic",
        },

        ["[d"] = {
            function()
                vim.diagnostic.goto_prev({ float = { border = "rounded" } })
            end,
            "Goto prev",
        },

        ["]d"] = {
            function()
                vim.diagnostic.goto_next({ float = { border = "rounded" } })
            end,
            "Goto next",
        },

        ["<leader>q"] = {
            function()
                vim.diagnostic.setloclist()
            end,
            "Diagnostic setloclist",
        },
    },

    v = {
        ["<leader>la"] = {
            function()
                vim.lsp.buf.code_action()
            end,
            "LSP code action",
        },
    },
}

M.nvimtree = {
    plugin = true,

    n = {
        -- focus
        ["<leader>oe"] = { "<cmd> NvimTreeFocus <CR>", "Focus explorer" },
    },
}

M.telescope = {
    plugin = true,

    n = {
        -- find
        ["<leader>ff"] = { "<cmd> Telescope find_files <CR>", "Find files" },
        ["<leader>fa"] = { "<cmd> Telescope find_files follow=true no_ignore=true hidden=true <CR>", "Find all" },
        ["<leader>fw"] = { "<cmd> Telescope live_grep <CR>", "Live grep" },
        ["<leader>fb"] = { "<cmd> Telescope buffers <CR>", "Find buffers" },
        ["<leader>fh"] = { "<cmd> Telescope help_tags <CR>", "Help page" },
        ["<leader>fo"] = { "<cmd> Telescope oldfiles <CR>", "Find oldfiles" },
        ["<leader>fz"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current buffer" },
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
                    require("gitsigns").next_hunk()
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
                    require("gitsigns").prev_hunk()
                end)
                return "<Ignore>"
            end,
            "Jump to prev hunk",
            opts = { expr = true },
        },

        -- Actions
        ["<leader>gr"] = {
            function()
                require("gitsigns").reset_hunk()
            end,
            "Reset hunk",
        },

        ["<leader>gp"] = {
            function()
                require("gitsigns").preview_hunk()
            end,
            "Preview hunk",
        },

        ["<leader>gb"] = {
            function()
                package.loaded.gitsigns.blame_line()
            end,
            "Blame line",
        },

        ["<leader>gt"] = {
            function()
                require("gitsigns").toggle_deleted()
            end,
            "Toggle deleted",
        },

        ["<leader>gm"] = { "<cmd> Telescope git_commits <CR>", "Git commits" },
        ["<leader>gs"] = { "<cmd> Telescope git_status <CR>", "Git status" },
    },
}

return M
