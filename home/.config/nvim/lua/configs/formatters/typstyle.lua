local utils = require("utils")

return {
    filetype = { "typst" },
    priority = 1,
    command = "typstyle",
    cwd = utils.root_file({ ".git" }),
}
