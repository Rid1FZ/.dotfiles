---@type vim.lsp.Config
return {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    root_markers = { ".git" },
    settings = {
        formatterMode = "disable",
        exportPdf = "never",
        syntaxOnly = "disable",
        projectResolution = "lockDatabase",
        lint = {
            enabled = true,
            when = "onType",
        },
    },
}
