---@type vim.lsp.Config
return {
    cmd = { "bash-language-server", "start" },
    root_markers = { ".git" },
    filetypes = { "bash", "sh" },
}
