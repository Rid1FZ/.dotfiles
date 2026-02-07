local M = {}

local lsp = vim.lsp
local diagnostic = vim.diagnostic

--------------------------------------------------------------------
-- General Mappings
--------------------------------------------------------------------
M.general = {
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
                require("utils.floattui").open("htop")
            end,
            "Open htop",
        },

        ["<Leader>ol"] = {
            function()
                require("utils.floattui").open("lazygit")
            end,
            "Open lazygit",
        },

        ["<Leader>ot"] = {
            function()
                require("utils.floattui.terminal").open()
            end,
            "Open terminal",
        },
    },

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

--------------------------------------------------------------------
-- Plugin/Config specific mappings
--------------------------------------------------------------------

M.completion = {
    plugin = true,
    i = {
        ["<C-n>"] = {
            function()
                lsp.completion.get()
            end,
            "Trigger completion",
        },
    },
}

M.lsp = {
    plugin = true,
    n = {
        ["gD"] = {
            function()
                lsp.buf.declaration()
            end,
            "LSP declaration",
        },

        ["gd"] = {
            function()
                require("fzf-lua").lsp_definitions()
            end,
            "LSP definition",
        },

        ["K"] = {
            function()
                lsp.buf.hover()
            end,
            "LSP hover",
        },

        ["gi"] = {
            function()
                require("fzf-lua").lsp_implementations()
            end,
            "LSP implementation",
        },

        ["<leader>ls"] = {
            function()
                lsp.buf.signature_help()
            end,
            "LSP signature help",
        },

        ["<leader>lf"] = {
            function()
                local providers = {
                    "null-ls",
                }
                lsp.buf.format({
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

        ["<leader>ld"] = {
            function()
                diagnostic.open_float({
                    border = "rounded",
                    scope = "cursor",
                    severity_sort = true,
                })
            end,
            "Floating diagnostic",
        },

        ["<leader>lD"] = {
            function()
                require("fzf-lua").lsp_workspace_diagnostics()
            end,
            "LSP list all diagnostics",
        },

        ["<leader>lr"] = {
            function()
                lsp.buf.rename()
            end,
            "LSP rename",
        },

        ["<leader>la"] = {
            function()
                lsp.buf.code_action()
            end,
            "LSP code action",
        },

        ["gr"] = {
            function()
                require("fzf-lua").lsp_references()
            end,
            "LSP references",
        },

        ["[d"] = {
            function()
                diagnostic.jump({
                    count = -1,
                    float = {
                        border = "rounded",
                    },
                })
            end,
            "Goto prev",
        },

        ["]d"] = {
            function()
                diagnostic.jump({
                    count = 1,
                    float = {
                        border = "rounded",
                    },
                })
            end,
            "Goto next",
        },

        ["<leader>q"] = {
            function()
                diagnostic.setloclist()
            end,
            "Diagnostic setloclist",
        },
    },

    v = {
        ["<leader>la"] = {
            function()
                lsp.buf.code_action()
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
                require("nvim-tree.api").tree.focus()
            end,
            "Focus explorer",
        },
    },
}

M["fzf-lua"] = {
    plugin = true,

    n = {
        -- find
        ["<leader>ff"] = {
            function()
                require("fzf-lua").files()
            end,
            "Find files",
        },

        ["<leader>fg"] = {
            function()
                require("fzf-lua").live_grep()
            end,
            "Live grep",
        },

        ["<leader>fb"] = {
            function()
                require("fzf-lua").buffers()
            end,
            "Find buffers",
        },

        ["<leader>fh"] = {
            function()
                require("fzf-lua").helptags()
            end,
            "Help page",
        },

        ["<leader>fo"] = {
            function()
                require("fzf-lua").oldfiles()
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
                require("gitsigns").nav_hunk("next")
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
                require("gitsigns").nav_hunk("prev")
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
                require("gitsigns").blame_line()
            end,
            "Blame line",
        },

        ["<leader>gt"] = {
            function()
                require("gitsigns").preview_hunk_inline()
            end,
            "Toggle deleted",
        },

        ["<leader>gm"] = {
            function()
                require("fzf-lua").git_commits()
            end,
            "Git commits",
        },

        ["<leader>gs"] = {
            function()
                require("fzf-lua").git_status()
            end,
            "Git status",
        },
    },
}

return M
