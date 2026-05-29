---@type vim.lsp.Config
return {
    cmd = { "nixd" },
    root_markers = { ".git", "flake.nix" },
    filetypes = { "nix" },
}
