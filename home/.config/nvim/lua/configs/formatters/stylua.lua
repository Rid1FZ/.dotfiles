return {
    filetype = { "lua" },
    priority = 1,
    command = "stylua",
    args = { "--search-parent-directories", "--respect-ignores", "--stdin-filepath", "$FILENAME", "-" },
    root_markers = { ".stylua.toml", "stylua.toml" },
}
