local lsp = require("configs.lsp")

return {
    cmd = { "clangd", "--background-index" },
    root_markers = { ".git" },
    filetypes = { "c", "cpp" },
    capabilities = (function()
        ---@class lsp.ClientCapabilities
        local capabilities = vim.deepcopy(lsp.capabilities, true)

        capabilities.offsetEncoding = { "utf-16" }

        return capabilities
    end)(),
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
}
