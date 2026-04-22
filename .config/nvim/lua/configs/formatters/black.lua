local utils = require("utils")

return {
    filetype = { "python" },
    priority = 2, -- priority:1 will be for isort
    command = "black",
    args = { "--stdin-filename", "$FILENAME", "--quiet", "-" },
    cwd = utils.root_file({ "pyproject.toml" }),
}
