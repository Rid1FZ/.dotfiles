return {
    filetype = { "python" },
    priority = 2, -- priority:1 will be for ruff_iformat.lua
    command = "ruff",
    args = { "format", "--stdin-filename", "$FILENAME", "--quiet", "-" },
    root_markers = { "pyproject.toml", ".git" },
}
