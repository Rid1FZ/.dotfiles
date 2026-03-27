---@class Completions
local M = {}

local highlights = require("utils.completions.highlights")

local api = vim.api
local fn = vim.fn
local bo = vim.bo -- always use the index form: bo[something]
local lsp = vim.lsp
local schedule = vim.schedule
local list_extend = vim.list_extend

---Setup LSP-based autocompletion
---@return nil
M.setup = function()
    -- Setup highlights
    schedule(function() highlights.setup_highlights() end)

    local group = api.nvim_create_augroup("CompletionsSetup", { clear = true })

    api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            schedule(function()
                local client = assert(lsp.get_client_by_id(args.data.client_id))
                if not client then
                    return
                end

                local bufnr = args.buf
                if
                    bo[bufnr].buftype ~= ""
                    or bo[bufnr].filetype == ""
                    or not client:supports_method("textDocument/completion")
                then
                    return
                end

                -- Set a more reasonable list of trigger characters
                ---@type string[]
                local default_triggers = client.server_capabilities.completionProvider
                        and client.server_capabilities.completionProvider.triggerCharacters
                    or {}
                local extra_triggers = { ".", ":", "<", "'", '"', "/", "\\" }
                local merged = list_extend(extra_triggers, default_triggers)
                client.server_capabilities.completionProvider.triggerCharacters = fn.uniq(fn.sort(merged))

                -- Enable completion
                lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

                -- Load mappings
                require("utils").load_mappings("completions", { buffer = bufnr })
            end)
        end,
    })
end

return M
