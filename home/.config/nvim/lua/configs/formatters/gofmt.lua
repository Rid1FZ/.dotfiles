return {
    filetype = { "go" },
    priority = 2, -- priority:1 will be goimports
    command = "gofmt",
    root_markers = { "go.mod", ".git" },
}
