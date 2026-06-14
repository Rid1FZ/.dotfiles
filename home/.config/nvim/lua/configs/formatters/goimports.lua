return {
    filetype = { "go" },
    priority = 1,
    command = "goimports",
    args = { "-srcdir", "$DIRNAME" },
    root_markers = { "go.mod", ".git" },
}
