local utils = require("utils")

return {
    filetype = { "tex", "plaintex" },
    priority = 1,
    command = "latexindent",
    args = { "-" },
    cwd = utils.root_file({ ".git", ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml" }),
}
