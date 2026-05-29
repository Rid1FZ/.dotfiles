local utils = require("utils")

return {
    filetype = { "lua" },
    priority = 1,
    command = "stylua",
    args = { "--search-parent-directories", "--respect-ignores", "--stdin-filepath", "$FILENAME", "-" },
    cwd = utils.root_file({ ".stylua.toml", "stylua.toml" }),
}
