---@type vim.lsp.Config
return {
    cmd = { "basedpyright-langserver", "--stdio" },
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
