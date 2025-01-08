local nvim_tree_api = require("nvim-tree.api")
local Event = nvim_tree_api.events.Event
local tree = require("nvim-tree.api").tree
local tbuiltin = require("telescope.builtin")

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

-- Open Telescope Find Files for Directories
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = NvimTreeAugroup,
    callback = function(data)
        if not vim.fn.isdirectory(data.file) == 1 then
            return
        end

        vim.cmd("bwipeout")
        vim.cmd.cd(data.file)
        vim.schedule(function()
            tbuiltin.find_files()
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

-- Do Not Take Full Width When File Is Removed
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
