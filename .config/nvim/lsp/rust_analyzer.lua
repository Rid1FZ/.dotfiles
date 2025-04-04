local lsp = require("configs.lsp")

return {
    cmd = { "rust-analyzer" },
    root_markers = { ".git", "Cargo.toml" },
    filetypes = { "rust" },
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,

    settings = {
        ["rust_analyzer"] = {
            cargo = {
                allFeatures = true,
            },
        },
    },
}
