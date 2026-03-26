local util = require("utils.conform.util")
return {
    filetype = { "lua" },
    priority = 1,
    command = "stylua",
    args = { "--search-parent-directories", "--respect-ignores", "--stdin-filepath", "$FILENAME", "-" },
    cwd = util.root_file({ ".stylua.toml", "stylua.toml" }),
}
