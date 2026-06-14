---@class Completions
local M = {}

local highlights = require("utils.completions.highlights")

local api = vim.api
local bo = vim.bo -- always use the index form: bo[something]
local lsp = vim.lsp
local schedule = vim.schedule
local list_extend = vim.list_extend

local setup_autocommands = function()
    local group = api.nvim_create_augroup("CompletionsSetup", { clear = true })

    api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client_id = args.data.client_id
            local bufnr = args.buf

            schedule(function()
                -- Client may have detached between LspAttach and the scheduled tick.
                local client = lsp.get_client_by_id(client_id)
                if not client then
                    return
                end

                -- Buffer may have been wiped between LspAttach and the scheduled tick.
                if not api.nvim_buf_is_valid(bufnr) then
                    return
                end

                if
                    bo[bufnr].buftype ~= ""
                    or bo[bufnr].filetype == ""
                    or not client:supports_method("textDocument/completion")
                then
                    return
                end

                -- Merge server trigger characters with a sensible extra set.
                -- vim.list.unique() requires sorted input (undefined on unsorted lists),
                -- so table.sort first.
                ---@type string[]
                local default_triggers = client.server_capabilities.completionProvider
                        and client.server_capabilities.completionProvider.triggerCharacters
                    or {}
                local extra_triggers = { ".", ":", "<", "'", '"', "/", "\\" }
                local merged = list_extend(extra_triggers, default_triggers)
                table.sort(merged)
                client.server_capabilities.completionProvider.triggerCharacters = vim.list.unique(merged)

                -- Enable completion
                lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

                -- Load mappings
                require("utils").load_mappings("completions", { buffer = bufnr })
            end)
        end,
    })

    api.nvim_create_autocmd("ColorScheme", {
        group = group,
        callback = function() highlights.setup_highlights() end,
    })
end

---Setup LSP-based autocompletion
---@return nil
M.setup = function()
    highlights.setup_highlights()
    setup_autocommands()
end

return M
