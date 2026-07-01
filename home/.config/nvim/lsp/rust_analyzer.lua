---@type vim.lsp.Config
return {
    cmd = { "rust-analyzer" },
    root_markers = { ".git", "Cargo.toml" },
    filetypes = { "rust" },

    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
            lens = {
                debug = { enable = true },
                enable = true,
                implementations = { enable = true },
                references = {
                    adt = { enable = true },
                    enumVariant = { enable = true },
                    method = { enable = true },
                    trait = { enable = true },
                },
                run = { enable = true },
                updateTest = { enable = true },
            },
            check = {
                command = "clippy",
            },
        },
    },
}
