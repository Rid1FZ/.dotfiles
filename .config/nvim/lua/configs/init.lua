local M = {}

M.setup_autocommands = function()
    local ok_fzf, fzflua = pcall(require, "fzf-lua")

    local groups = {
        qf = vim.api.nvim_create_augroup("QFNoList", { clear = true }),
        file_post = vim.api.nvim_create_augroup("CustomFilePost", { clear = true }),
        open_find = vim.api.nvim_create_augroup("OpenFindFiles", { clear = true }),
        yank = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
        disable_search = vim.api.nvim_create_augroup("DisableSearchHighlighting", { clear = true }),
    }

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        group = groups.qf,
        callback = function()
            vim.opt_local.buflisted = false
        end,
    })

    vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
        group = groups.file_post,
        callback = function(args)
            local file = vim.api.nvim_buf_get_name(args.buf)
            local buftype = vim.bo[args.buf].buftype

            -- Mark UI as entered
            if not vim.g.ui_entered and args.event == "UIEnter" then
                vim.g.ui_entered = true
            end

            if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
                vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
                vim.api.nvim_del_augroup_by_id(groups.file_post)

                vim.schedule(function()
                    vim.api.nvim_exec_autocmds("FileType", {})

                    if vim.g.editorconfig then
                        local ok, editorconfig = pcall(require, "editorconfig")
                        if ok then
                            editorconfig.config(args.buf)
                        end
                    end
                end)
            end
        end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = groups.open_find,
        callback = function(data)
            if vim.fn.isdirectory(data.file) ~= 1 or not ok_fzf then
                return
            end

            vim.cmd("bwipeout")
            vim.cmd.cd(data.file)
            vim.schedule(function()
                fzflua.files()
            end)
        end,
    })

    vim.api.nvim_create_autocmd("TextYankPost", {
        group = groups.yank,
        callback = function()
            vim.highlight.on_yank({ timeout = 150 })
        end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
        group = groups.disable_search,
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
