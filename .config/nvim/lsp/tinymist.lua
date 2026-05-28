---@type vim.lsp.Config
return {
    cmd = { "tinymist" },
    filetypes = { "typst" },
    root_markers = { ".git" },
    settings = {
        formatterMode = "disable",
        exportPdf = "never",
        -- Hot reload: set exportPdf = "onSave" (or "onType") and
        -- configure outputPath = "$dir/$name" if needed
    },
}
