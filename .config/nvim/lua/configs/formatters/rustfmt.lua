local util = require("utils.conform.util")
return {
    filetype = { "rust" },
    priority = 1,
    command = "rustfmt",
    args = function(self, ctx)
        local edition = util.parse_rust_edition(ctx.dirname) or "2021"
        return { "--edition", edition, "--stdin-filepath", "$FILENAME" }
    end,
    cwd = util.root_file({ "Cargo.toml" }),
}
