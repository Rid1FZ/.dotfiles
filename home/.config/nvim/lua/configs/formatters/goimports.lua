local utils = require("utils")

return {
    filetype = { "go" },
    priority = 1,
    command = "goimports",
    args = { "-srcdir", "$DIRNAME" },
    cwd = utils.root_file({ ".git", "go.mod" }),
}
