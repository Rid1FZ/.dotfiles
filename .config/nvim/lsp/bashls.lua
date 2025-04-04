local lsp = require("configs.lsp")

return {
    cmd = { "bash-language-server", "start" },
    root_markers = { ".git" },
    filetypes = { "bash", "sh" },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
}
