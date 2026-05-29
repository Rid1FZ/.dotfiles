---@class LspConfig
local M = {}

local utils = require("utils")

local diagnostic = vim.diagnostic
local lsp = vim.lsp
local api = vim.api
local fn = vim.fn

---@return nil
M.configure_diagnostics = function()
    local severity = diagnostic.severity

    diagnostic.config({
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
    })
end

---LSP on_attach callback
---@param client vim.lsp.Client The LSP client
---@param bufnr integer The buffer number
---@return nil
local function on_attach(client, bufnr) utils.load_mappings("lsp", { buffer = bufnr }) end

---@type lsp.ClientCapabilities
local capabilities = lsp.protocol.make_client_capabilities()

capabilities.textDocument.completion.completionItem = {
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

---Apply default options to all the lsp servers
---@return nil
local function apply_defaults()
    lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
    })
end

---Setup LSP servers
---@return nil
M.setup = function()
    apply_defaults()

    local configs = {}
    for _, v in ipairs(api.nvim_get_runtime_file("lsp/*", true)) do
        local name = fn.fnamemodify(v, ":t:r")
        configs[name] = true
    end

    lsp.enable(vim.tbl_keys(configs))
end

return M
