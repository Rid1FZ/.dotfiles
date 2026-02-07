local M = {}

local utils = require("utils")

local opt_local = vim.opt_local
local bo = vim.bo -- always use the index form: bo[something]
local api = vim.api
local g = vim.g
local cmd = vim.cmd
local schedule = vim.schedule
local defer_fn = vim.defer_fn
local fn = vim.fn

M.setup_custom_events = function()
    --------------------------------------------------------------------
    -- All augroups
    --------------------------------------------------------------------
    local groups = {
        file_post = api.nvim_create_augroup("CustomFilePost", { clear = true }),
    }

    --------------------------------------------------------------------
    -- Triggered when file is opened
    --------------------------------------------------------------------
    api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
        group = groups.file_post,
        callback = function(args)
            local file = api.nvim_buf_get_name(args.buf)
            local buftype = bo[args.buf].buftype

            -- Mark UI as entered
            if not g.ui_entered and args.event == "UIEnter" then
                g.ui_entered = true
            end

            if file ~= "" and buftype ~= "nofile" and g.ui_entered then
                api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
                api.nvim_del_augroup_by_id(groups.file_post)

                schedule(function()
                    api.nvim_exec_autocmds("FileType", {})

                    if g.editorconfig then
                        local ok, editorconfig = pcall(require, "editorconfig")
                        if ok then
                            editorconfig.config(args.buf)
                        end
                    end
                end)
            end
        end,
    })
end

M.setup_autocommands = function()
    local ok_fzf, fzflua = pcall(require, "fzf-lua")
    local ok_nvim_tree_api, nvim_tree_api = pcall(require, "nvim-tree.api")

    local tree = nil

    if ok_nvim_tree_api then
        tree = nvim_tree_api.tree
    end

    --------------------------------------------------------------------
    -- All augroups
    --------------------------------------------------------------------
    local groups = {
        qf = api.nvim_create_augroup("QFNoList", { clear = true }),
        open_find = api.nvim_create_augroup("OpenFindFiles", { clear = true }),
        yank = api.nvim_create_augroup("HighlightYank", { clear = true }),
        disable_search = api.nvim_create_augroup("DisableSearchHighlighting", { clear = true }),
        start_treesitter = api.nvim_create_augroup("StartTreesitter", { clear = true }),
        nvim_tree = api.nvim_create_augroup("NvimTreeAugroup", { clear = true }),
    }

    --------------------------------------------------------------------
    -- Close NvimTree if Last Window
    --------------------------------------------------------------------
    api.nvim_create_autocmd("QuitPre", {
        group = groups.nvim_tree,
        callback = function()
            local invalid_win = {}
            local wins = api.nvim_list_wins()

            for _, w in ipairs(wins) do
                local bufname = api.nvim_buf_get_name(api.nvim_win_get_buf(w))
                if bufname:match("NvimTree_") ~= nil then
                    table.insert(invalid_win, w)
                end
            end

            if #invalid_win == #wins - 1 then
                -- Should quit, so we close all invalid windows.
                for _, w in ipairs(invalid_win) do
                    api.nvim_win_close(w, true)
                end
            end
        end,
    })

    --------------------------------------------------------------------
    -- Make :bd and :q behave as usual when tree is visible (NvimTree)
    --------------------------------------------------------------------
    api.nvim_create_autocmd({ "BufEnter", "QuitPre" }, {
        group = groups.nvim_tree,
        nested = false,
        callback = function(e)
            if not tree then
                return
            elseif not tree.is_visible() then
                return
            end

            local winCount = 0
            for _, winId in ipairs(api.nvim_list_wins()) do
                if api.nvim_win_get_config(winId).focusable then
                    winCount = winCount + 1
                end
            end

            -- We want to quit and only one window besides tree is left
            if e.event == "QuitPre" and winCount == 2 then
                api.nvim_cmd({ cmd = "qall" }, {})
            end

            if e.event == "BufEnter" and winCount == 1 then
                -- Required to avoid "Vim:E444: Cannot close last window"
                defer_fn(function()
                    tree.toggle({ find_file = true, focus = true })
                    tree.toggle({ find_file = true, focus = false })
                end, 10)
            end
        end,
    })

    --------------------------------------------------------------------
    -- Hide quickfix from buffer list
    --------------------------------------------------------------------
    api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        group = groups.qf,
        callback = function()
            opt_local["buflisted"] = false
        end,
    })

    --------------------------------------------------------------------
    -- Open file search when vim is opened with directory
    --------------------------------------------------------------------
    api.nvim_create_autocmd("VimEnter", {
        group = groups.open_find,
        callback = function(data)
            if fn.isdirectory(data.file) ~= 1 or not ok_fzf then
                return
            end

            cmd("bwipeout")
            cmd.cd(data.file)
            schedule(function()
                fzflua.files()
            end)
        end,
    })

    --------------------------------------------------------------------
    -- Highlight yanked part
    --------------------------------------------------------------------
    api.nvim_create_autocmd("TextYankPost", {
        group = groups.yank,
        callback = function()
            vim.highlight.on_yank({ timeout = 150 })
        end,
    })

    --------------------------------------------------------------------
    -- Disable search highlighting for specific buffers
    --------------------------------------------------------------------
    api.nvim_create_autocmd("WinEnter", {
        group = groups.disable_search,
        callback = function()
            defer_fn(function()
                local bufnr = api.nvim_get_current_buf()
                local curr_buftype = bo[bufnr].buftype
                local disabled_bufs = {
                    "terminal",
                }

                for _, buftype in ipairs(disabled_bufs) do
                    if curr_buftype == buftype then
                        opt_local["winhighlight"] = opt_local["winhighlight"]
                            + "Search:None,CurSearch:None,IncSearch:None"
                        break
                    end
                end
            end, 10)
        end,
    })

    --------------------------------------------------------------------
    -- Start treesitter when a file is opened
    --------------------------------------------------------------------
    api.nvim_create_autocmd("FileType", {
        group = groups.start_treesitter,
        callback = function(args)
            local curr_win = api.nvim_get_current_win()

            utils.start_treesitter(args.buf, curr_win)
        end,
    })
end

return M
