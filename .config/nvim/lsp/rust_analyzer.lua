return {
    cmd = { "rust-analyzer" },
    root_markers = { ".git", "Cargo.toml" },
    filetypes = { "rust" },

    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allFeatures = true,
            },
        },
    },
}
