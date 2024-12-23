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

-- Open NvimTree for Directories
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    group = NvimTreeAugroup,
    callback = function(data)
        local isdirectory = (vim.fn.isdirectory(data.file) == 1)

        if not isdirectory then
            return
        end
        vim.cmd("bwipeout")
        vim.cmd.cd(data.file)

        require("nvim-tree.api").tree.open({
            current_window = false,
        })
    end,
})

-- Highlight Yanked Part
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
