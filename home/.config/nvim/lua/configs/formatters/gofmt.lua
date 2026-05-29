local utils = require("utils")

return {
    filetype = { "go" },
    priority = 2, -- priority:1 will be goimports
    command = "gofmt",
    cwd = utils.root_file({ ".git", "go.mod" }),
}
