local utils = require("utils")

return {
    filetype = { "python" },
    priority = 1,
    command = "ruff",
    args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "--quiet", "-" },
    cwd = utils.root_file({ ".isort.cfg", "pyproject.toml", "setup.py", "setup.cfg", "tox.ini", ".editorconfig" }),
}
