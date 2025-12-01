local M = {}

local lsp = vim.lsp
local api = vim.api
local fn = vim.fn

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
    local util_open_floating_preview_ = lsp.util.open_floating_preview
    function lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = "rounded"
        return util_open_floating_preview_(contents, syntax, opts, ...)
    end
end

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
    require("utils").load_mappings("lsp", { buffer = bufnr })
end

-- disable semantic tokens
M.on_init = function(client, _)
    if not client.supports_method("textDocument/semanticTokens") then
        client.server_capabilities.semanticTokensProvider = nil
    end
end

M.capabilities = lsp.protocol.make_client_capabilities()

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

M.setup = function()
    local configs = {}

    -- enable lsp
    for _, v in ipairs(api.nvim_get_runtime_file("lsp/*", true)) do
        local name = fn.fnamemodify(v, ":t:r")
        configs[name] = true
    end

    lsp.enable(vim.tbl_keys(configs))
end

return M
