local lsp = require("configs.lsp")

return {
    cmd = { "pyright-langserver", "--stdio" },
    root_markers = { ".git", "pyproject.toml" },
    filetypes = { "python" },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,

    settings = {
        ["python"] = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
            },
        },
    },
}
