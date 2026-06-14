return {
    filetype = { "c", "cpp" },
    command = "clang-format",
    args = { "-assume-filename", "$FILENAME" },
    root_markers = { ".clang-format", ".git" },
}
