local M = {}

local breadcrumb = require("breadcrumb")

M.configure_diagnostics = function()
    local severity = vim.diagnostic.severity

    vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = true,
        signs = {
            text = {
                [severity.ERROR] = "",
                [severity.WARN] = "",
                [severity.INFO] = "",
                [severity.HINT] = "",
            },
        },
        underline = true,
        float = { border = "single" },
    })

    -- Default border style
    local util_open_floating_preview_ = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return util_open_floating_preview_(contents, syntax, opts, ...)
    end
end

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
    require("utils").load_mappings("lspconfig", { buffer = bufnr })
    if client.server_capabilities.signatureHelpProvider then
        require("utils.signature").setup(client)
    end
end

-- disable semantic tokens
M.on_init = function(client, _)
    if not client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

M.capabilities = vim.lsp.protocol.make_client_capabilities()

M.capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
        properties = {
            "documentation",
            "detail",
            "additionalTextEdits",
        },
    },
}

return M
