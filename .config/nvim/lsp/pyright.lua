local lsp = require("configs.lsp")

return {
    cmd = { "pyright-langserver", "--stdio" },
    root_markers = { ".git" },
    filetypes = { "python" },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
}
