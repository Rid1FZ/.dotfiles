require("utils.lsp")

local M = {}
local lspconfig = require("lspconfig")

-- export on_attach & capabilities for custom lspconfigs
M.on_attach = function(client, bufnr)
    require("utils").load_mappings("lspconfig", { buffer = bufnr })

    if client.server_capabilities.signatureHelpProvider then require("utils.signature").setup(client) end
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

lspconfig.pyright.setup({
    capabilities = M.capabilities,
    on_attach = M.on_attach,
    on_init = M.on_init,
})

lspconfig.clangd.setup({
    capabilities = M.capabilities,
    on_attach = M.on_attach,
    on_init = M.on_init,
})

lspconfig.lua_ls.setup({
    on_init = M.on_init,
    on_attach = M.on_attach,
    capabilities = M.capabilities,

    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                    [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})

return M
