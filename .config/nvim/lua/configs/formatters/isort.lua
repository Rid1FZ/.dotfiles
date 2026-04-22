local utils = require("utils")

return {
    filetype = { "python" },
    priority = 1,
    command = "isort",
    args = function(self, ctx)
        return { "--stdout", "--line-ending", utils.buf_line_ending(ctx.buf), "--filename", "$FILENAME", "-" }
    end,
    cwd = utils.root_file({ ".isort.cfg", "pyproject.toml", "setup.py", "setup.cfg", "tox.ini", ".editorconfig" }),
}
