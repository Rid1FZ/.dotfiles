local lsp = vim.lsp

---@class lsp.ClientCapabilities
local capabilities = vim.deepcopy(lsp.protocol.make_client_capabilities(), true)
capabilities.offsetEncoding = { "utf-16" }

return {
    cmd = { "clangd", "--background-index" },
    root_markers = { ".git" },
    filetypes = { "c", "cpp" },
    capabilities = capabilities,
}
