local lsp = require("configs.lsp")

return {
    cmd = { "docker-langserver", "--stdio" },
    root_markers = { ".git", "Dockerfile" },
    filetypes = { "dockerfile" },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
}
