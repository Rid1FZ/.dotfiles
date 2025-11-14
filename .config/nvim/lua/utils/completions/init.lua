local M = {}

local highlights = require("utils.completions.highlights")

M.setup = function()
    -- Setup highlights
    highlights.setup_highlights()

    local group = vim.api.nvim_create_augroup("CompletionsSetup", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
            local bufnr = args.buf

            -- Skip buffers where completions are irrelevant
            if vim.bo[bufnr].buftype ~= "" or vim.bo[bufnr].filetype == "" then
                return
            end

            if not client:supports_method("textDocument/completion") then
                return
            end

            -- Set a more reasonable list of trigger characters
            local default_triggers
            if client.server_capabilities.completionProvider then
                default_triggers = client.server_capabilities.completionProvider.triggerCharacters
            else
                default_triggers = {}
            end

            -- Extend trigger characters for common cases
            local extra_triggers = { ".", ":", ">", "<", "'", '"', "/", "\\" }

            -- Merge and deduplicate triggers
            local merged = vim.list_extend(extra_triggers, default_triggers)

            client.server_capabilities.completionProvider.triggerCharacters = merged

            -- Enable autotrigger safely
            if vim.lsp.completion and vim.lsp.completion.enable then
                vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
                require("utils").load_mappings("completion", { buffer = bufnr })
            else
                vim.notify("LSP completion API not available in this Neovim version", vim.log.levels.WARN)
            end
        end,
    })
end

return M
