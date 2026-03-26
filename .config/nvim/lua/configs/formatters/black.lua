local util = require("utils.conform.util")
return {
    filetype = { "python" },
    priority = 2,
    command = "black",
    args = { "--stdin-filename", "$FILENAME", "--quiet", "-" },
    cwd = util.root_file({ "pyproject.toml" }),
}
