local util = require("utils.conform.util")
return {
    filetype = { "python" },
    priority = 1,
    command = "isort",
    args = function(self, ctx)
        return { "--stdout", "--line-ending", util.buf_line_ending(ctx.buf), "--filename", "$FILENAME", "-" }
    end,
    cwd = util.root_file({ ".isort.cfg", "pyproject.toml", "setup.py", "setup.cfg", "tox.ini", ".editorconfig" }),
}
