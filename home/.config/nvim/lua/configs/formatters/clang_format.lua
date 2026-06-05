local utils = require("utils")

return {
    filetype = { "c", "cpp" },
    command = "clang-format",
    args = { "-assume-filename", "$FILENAME" },
    cwd = utils.root_file({ ".clang-format", ".git" }),
}
