local utils = require("utils")

---Parse the Rust edition from the nearest Cargo.toml above `dir`.
---Returns nil if not found or if the workspace inherits its edition.
---@param dir string Starting directory
---@return string|nil e.g. "2021"
local parse_rust_edition = function(dir)
    for _, manifest in ipairs(vim.fs.find("Cargo.toml", { upward = true, path = dir, limit = math.huge })) do
        for line in io.lines(manifest) do
            if line:match("^edition *= *{ *workspace *= *true *}") or line:match("^edition%.workspace *= *true") then
                break
            end
            local ed = line:match('^edition *= *"(%d+)"')
            if ed then
                return ed
            end
        end
    end
end

return {
    filetype = { "rust" },
    priority = 1,
    command = "rustfmt",
    args = function(self, ctx)
        local edition = parse_rust_edition(ctx.dirname) or "2021"
        return { "--edition", edition, "--emit", "stdout" }
    end,
    cwd = utils.root_file({ "Cargo.toml" }),
}
