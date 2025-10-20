local nvim_tree_api = require("nvim-tree.api")
local Event = nvim_tree_api.events.Event
local tree = require("nvim-tree.api").tree
local fzflua = require("fzf-lua")

-- Dont List Quickfix Buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    group = vim.api.nvim_create_augroup("QFNoList", { clear = true }),
    callback = function()
        vim.opt_local.buflisted = false
    end,
})

-- Custom Event
vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
    group = vim.api.nvim_create_augroup("CustomFilePost", { clear = true }),
    callback = function(args)
        local file = vim.api.nvim_buf_get_name(args.buf)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

        if not vim.g.ui_entered and args.event == "UIEnter" then
            vim.g.ui_entered = true
        end

        if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
            vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
            vim.api.nvim_del_augroup_by_name("CustomFilePost")

            vim.schedule(function()
                vim.api.nvim_exec_autocmds("FileType", {})

                if vim.g.editorconfig then
                    require("editorconfig").config(args.buf)
                end
            end)
        end
    end,
})

local NvimTreeAugroup = vim.api.nvim_create_augroup("NvimTreeAugroup", { clear = true })

-- Close NvimTree if Last Window
vim.api.nvim_create_autocmd("QuitPre", {
    group = NvimTreeAugroup,
    callback = function()
        local invalid_win = {}
        local wins = vim.api.nvim_list_wins()
        for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match("NvimTree_") ~= nil then
                table.insert(invalid_win, w)
            end
        end
        if #invalid_win == #wins - 1 then
            -- Should quit, so we close all invalid windows.
            for _, w in ipairs(invalid_win) do
                vim.api.nvim_win_close(w, true)
            end
        end
    end,
})

-- Do Not Take Full Width When File Is Removed(NvimTree)
nvim_tree_api.events.subscribe(Event.FileRemoved, function(data)
    local winCount = 0
    for _, winId in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(winId).focusable then
            winCount = winCount + 1
        end
    end
    if winCount == 2 then -- one is nvim-tree window, another is additional window
        vim.defer_fn(function()
            -- close nvim-tree: will go to the last buffer used before closing
            tree.toggle({ find_file = true, focus = true })
            -- re-open nivm-tree
            tree.toggle({ find_file = true, focus = true })
        end, 10)
    end
end)

-- Open Find Files Prompt for Directories
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = vim.api.nvim_create_augroup("OpenFindFiles", { clear = true }),
    callback = function(data)
        if vim.fn.isdirectory(data.file) ~= 1 then
            return
        end

        vim.cmd("bwipeout")
        vim.cmd.cd(data.file)
        vim.schedule(function()
            fzflua.files()
        end)
    end,
})

-- Highlight Yanked Part
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Disable Search Highlighting for Specific Window
vim.api.nvim_create_autocmd("WinEnter", {
    group = vim.api.nvim_create_augroup("DisableSearchHighlighting", { clear = true }),
    callback = function()
        vim.defer_fn(function()
            local opt = vim.opt_local
            local curr_filetype = vim.bo.filetype
            local disable_filetypes = {
                "NvimTree",
            }

            for _, filetype in ipairs(disable_filetypes) do
                if curr_filetype == filetype then
                    opt.winhighlight = opt.winhighlight + "Search:None,CurSearch:None,IncSearch:None"
                    break
                end
            end
        end, 10)
    end,
})

-- Built-in Autocompletion
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|
        if client:supports_method("textDocument/completion") then
            -- trigger autocompletion on EVERY keypress. May be slow!
            local chars = {}
            for i = 32, 126 do
                table.insert(chars, string.char(i))
            end
            client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})
