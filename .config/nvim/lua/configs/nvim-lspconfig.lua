local M = {}
local lspconfig = require("lspconfig")
local win = require("lspconfig.ui.windows")
local _default_opts = win.default_opts

local function lspSymbol(name, icon)
    local hl = "DiagnosticSign" .. name
    vim.fn.sign_define(hl, { text = icon, numhl = hl, texthl = hl })
end

lspSymbol("Error", "")
lspSymbol("Info", "")
lspSymbol("Hint", "")
lspSymbol("Warn", "")

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "single",
})

-- Borders for LspInfo winodw
win.default_opts = function(options)
    local opts = _default_opts(options)
    opts.border = "single"
    return opts
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

lspconfig.pyright.setup({
    capabilities = M.capabilities,
    on_attach = M.on_attach,
    on_init = M.on_init,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
            },
        },
    },
})

lspconfig.clangd.setup({
    capabilities = M.capabilities,
    on_attach = M.on_attach,
    on_init = M.on_init,
})

lspconfig.bashls.setup({
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
