local M = {}

local map = vim.keymap.set
local fn = vim.fn
local api = vim.api
local lsp = vim.lsp
local diagnostic = vim.diagnostic

---For replacing certain <C-x>... keymaps. Wrapper around `vim.api.nvim_feedkeys`.
---@param keys string
---@return nil
local function feedkeys(keys) api.nvim_feedkeys(api.nvim_replace_termcodes(keys, true, false, true), "n", true) end

---Wrapper around `vim.tbl_extend`.
---@param main_opts table
---@param extra_opts table
---@return table
local function tbl_merge(main_opts, extra_opts) return vim.tbl_extend("keep", main_opts, extra_opts) end

---Check if completion menu is visible. Wrapper around `vim.fn.pumvisible`.
---@return nil
local function pumvisible() return tonumber(fn.pumvisible()) ~= 0 end

---General set of mappings
---@return nil
M.general = function(_)
    -- Clear highlights
    map("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear highlights" })

    -- Window navigation (tmux-aware)
    map("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { desc = "Window left" })
    map("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { desc = "Window right" })
    map("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { desc = "Window up" })
    map("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { desc = "Window down" })

    -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
    -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
    -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
    map("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
    map("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
    map("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
    map("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })

    map("v", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
    map("v", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
    map("v", "<", "<gv", { desc = "Indent left" })
    map("v", ">", ">gv", { desc = "Indent right" })

    map("x", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, desc = "Move down" })
    map("x", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, desc = "Move up" })
    -- Don't copy the replaced text after pasting in visual mode
    -- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
    map("x", "p", 'p<cmd>let @+=@0<CR><cmd>let @"=@0<CR>', { silent = true, desc = "Don't copy replaced text" })

    -- Float UI
    map("n", "<Leader>oh", function() require("utils.floattui").open("htop") end, { desc = "Open htop" })
    map("n", "<Leader>ol", function() require("utils.floattui").open("lazygit") end, { desc = "Open lazygit" })
    map("n", "<Leader>ot", function() require("utils.floattui.terminal").open() end, { desc = "Open terminal" })
end

---Mappings for `mini.pairs` plugin
---@return nil
M["mini-pairs"] = function(_)
    map("i", "<CR>", function()
        if pumvisible() then
            if fn.complete_info({ "selected" }).selected ~= -1 then
                return api.nvim_replace_termcodes("<C-y>", true, false, true)
            else
                return api.nvim_replace_termcodes("<C-e>", true, false, true) .. require("mini.pairs").cr()
            end
        else
            return require("mini.pairs").cr()
        end
    end, { expr = true, noremap = true, replace_keycodes = false })
end

---Mappings for `vim.lsp.completion` completions
---@param opts? table
---@return nil
M.completions = function(opts)
    if not opts then
        opts = {}
    end

    ---@param desc string Description of the mapping
    local set_opts = function(desc) return tbl_merge({ desc = desc }, opts) end

    map("i", "<Tab>", function()
        if pumvisible() then
            feedkeys("<C-n>")
        elseif vim.snippet.active({ direction = 1 }) then
            vim.snippet.jump(1)
        else
            local col = api.nvim_win_get_cursor(0)[2]
            local before = col > 0 and api.nvim_get_current_line():sub(col, col) or ""
            if before:match("%S") then
                lsp.completion.get()
            else
                feedkeys("<Tab>")
            end
        end
    end, set_opts("Select next completion option or open completion menu"))

    map("i", "<S-Tab>", function()
        if pumvisible() then
            feedkeys("<C-p>")
        elseif vim.snippet.active({ direction = -1 }) then
            vim.snippet.jump(-1)
        else
            feedkeys("<S-Tab>")
        end
    end, set_opts("Select prev completion option or dedent"))

    map("s", "<BS>", "<C-o>s", set_opts("Remove snippet placeholder"))
end

---Mappings for lsp
---@param opts? table
---@return nil
M.lsp = function(opts)
    if not opts then
        opts = {}
    end

    ---@param desc string Description of the mapping
    local set_opts = function(desc) return tbl_merge({ desc = desc }, opts) end

    map("n", "gD", lsp.buf.declaration, set_opts("LSP declaration"))
    map("n", "gd", function() require("fzf-lua").lsp_definitions() end, set_opts("LSP definition"))
    map("n", "K", lsp.buf.hover, set_opts("LSP hover"))
    map("n", "gi", function() require("fzf-lua").lsp_implementations() end, set_opts("LSP implementation"))
    map("n", "<leader>ls", lsp.buf.signature_help, set_opts("LSP signature help"))
    map("n", "<leader>lf", require("utils.conform").format, set_opts("LSP formatting"))

    map(
        "n",
        "<leader>ld",
        function() diagnostic.open_float({ scope = "cursor", severity_sort = true }) end,
        set_opts("Floating diagnostic")
    )

    map(
        "n",
        "<leader>lD",
        function() require("fzf-lua").lsp_workspace_diagnostics() end,
        set_opts("LSP list all diagnostics")
    )
    map("n", "<leader>lr", lsp.buf.rename, set_opts("LSP rename"))
    map("n", "<leader>la", lsp.buf.code_action, set_opts("LSP code action"))
    map("v", "<leader>la", lsp.buf.code_action, set_opts("LSP code action"))
    map("n", "gr", function() require("fzf-lua").lsp_references() end, set_opts("LSP references"))
    map("n", "[d", function() diagnostic.jump({ count = -1, float = true }) end, set_opts("Goto prev diagnostic"))
    map("n", "]d", function() diagnostic.jump({ count = 1, float = true }) end, set_opts("Goto next diagnostic"))
    map("n", "<leader>q", diagnostic.setloclist, set_opts("Diagnostic setloclist"))
end

M["nvim-tree"] = function(_)
    local nvim_tree_api = require("nvim-tree.api")

    map("n", "<leader>oe", nvim_tree_api.tree.focus, { desc = "Focus explorer" })
end

---Mappings for `NvimTree` plugin
---@param opts table
---@return nil
M["nvim-tree.on-attach"] = function(opts)
    if not opts then
        opts = {}
    end

    local nvim_tree_api = require("nvim-tree.api")

    ---@param desc string Description of the mapping
    local function set_opts(desc)
        return tbl_merge({
            desc = "nvim-tree: " .. desc,
            noremap = true,
            silent = true,
            nowait = true,
        }, opts)
    end

    -- Fileops
    map("n", "a", nvim_tree_api.fs.create, set_opts("Create File Or Directory"))
    map("n", "d", nvim_tree_api.fs.trash, set_opts("Trash"))
    map("n", "D", nvim_tree_api.marks.bulk.trash, set_opts("Trash Marked"))
    map("n", "p", nvim_tree_api.fs.paste, set_opts("Paste"))
    map("n", "y", nvim_tree_api.fs.copy.node, set_opts("Copy"))
    map("n", "C", nvim_tree_api.fs.copy.absolute_path, set_opts("Copy Absolute Path"))
    map("n", "c", nvim_tree_api.fs.copy.basename, set_opts("Copy Basename"))
    map("n", "x", nvim_tree_api.fs.cut, set_opts("Cut"))
    map("n", "r", nvim_tree_api.fs.rename, set_opts("Rename"))
    map("n", "<C-r>", nvim_tree_api.fs.rename_full, set_opts("Rename: Full Path"))

    -- Navigation
    map("n", "<CR>", nvim_tree_api.node.open.edit, set_opts("Open"))
    map("n", "o", nvim_tree_api.node.open.edit, set_opts("Open"))
    map("n", "<2-LeftMouse>", nvim_tree_api.node.open.edit, set_opts("Open"))
    map("n", "O", nvim_tree_api.node.open.no_window_picker, set_opts("Open: No Window Picker"))
    map("n", "<Tab>", nvim_tree_api.node.open.preview, set_opts("Open Preview"))
    map("n", "<2-RightMouse>", nvim_tree_api.tree.change_root_to_node, set_opts("CD"))

    -- Others
    map("n", "<Space>", nvim_tree_api.marks.toggle, set_opts("Toggle Bookmark"))
    map("n", "q", nvim_tree_api.tree.close, set_opts("Close"))
    map("n", "R", nvim_tree_api.tree.reload, set_opts("Refresh"))
    map("n", "<S-k>", nvim_tree_api.node.show_info_popup, set_opts("Info"))
    map("n", ".", nvim_tree_api.node.run.cmd, set_opts("Run Command"))
    map("n", "-", nvim_tree_api.tree.change_root_to_parent, set_opts("Up"))
    map("n", "g?", nvim_tree_api.tree.toggle_help, set_opts("Help"))
    map("n", "H", nvim_tree_api.tree.toggle_hidden_filter, set_opts("Toggle Filter: Dotfiles"))
    map("n", "I", nvim_tree_api.tree.toggle_gitignore_filter, set_opts("Toggle Filter: Git Ignore"))
    map("n", "<Esc>", nvim_tree_api.live_filter.clear, set_opts("Live Filter: Clear"))
    map("n", "/", nvim_tree_api.live_filter.start, set_opts("Live Filter: Start"))
end

---Mappings for `fzf-lua` plugin
---@return nil
M["fzf-lua"] = function(_)
    map("n", "<leader>ff", function() require("fzf-lua").files() end, { desc = "Find files" })
    map("n", "<leader>fg", function() require("fzf-lua").live_grep() end, { desc = "Live grep" })
    map("n", "<leader>fb", function() require("fzf-lua").buffers() end, { desc = "Find buffers" })
    map("n", "<leader>fh", function() require("fzf-lua").helptags() end, { desc = "Help page" })
    map("n", "<leader>fo", function() require("fzf-lua").oldfiles() end, { desc = "Find oldfiles" })
    map("n", "<leader>gm", function() require("fzf-lua").git_commits() end, { desc = "Git commits" })
    map("n", "<leader>gs", function() require("fzf-lua").git_status() end, { desc = "Git status" })
end

---Mappings for `mini.diff` plugin
---@return nil
M["mini-diff"] = function(_)
    map("n", "]c", function()
        if vim.wo.diff then
            return "]c"
        end
        require("mini.diff").goto_hunk("next")
        return "<Ignore>"
    end, { expr = true, desc = "Jump to next hunk" })

    map("n", "[c", function()
        if vim.wo.diff then
            return "[c"
        end
        require("mini.diff").goto_hunk("prev")
        return "<Ignore>"
    end, { expr = true, desc = "Jump to prev hunk" })
end

return M
