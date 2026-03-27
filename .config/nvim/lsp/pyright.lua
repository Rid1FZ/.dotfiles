return {
    cmd = { "pyright-langserver", "--stdio" },
    root_markers = { ".git", "pyproject.toml" },
    filetypes = { "python" },

    settings = {
        ["python"] = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
            },
        },
    },
}
