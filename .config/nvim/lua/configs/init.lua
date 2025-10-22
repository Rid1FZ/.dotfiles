local M = {}

M.setup_autocommands = function()
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
                local curr_buftype = vim.bo.buftype
                local disabled_bufs = {
                    "terminal",
                }

                for _, buftype in ipairs(disabled_bufs) do
                    if curr_buftype == buftype then
                        opt.winhighlight = opt.winhighlight + "Search:None,CurSearch:None,IncSearch:None"
                        break
                    end
                end
            end, 10)
        end,
    })
end

return M
