return {
    filetype = { "nix" },
    priority = 1,
    command = "nixfmt",
    root_markers = { "flake.nix", ".git" },
}
