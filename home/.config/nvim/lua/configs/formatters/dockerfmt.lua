return {
    filetype = { "dockerfile" },
    priority = 1,
    command = "dockerfmt",
    root_markers = { "Dockerfile", ".git" },
}
