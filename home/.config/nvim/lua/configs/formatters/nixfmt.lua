local utils = require("utils")

return {
    filetype = { "nix" },
    priority = 1,
    command = "nixfmt",
    cwd = utils.root_file({ ".git", "flake.nix" }),
}
