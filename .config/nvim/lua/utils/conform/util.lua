---@class Util
local M = {}

---Return a command resolver that prefers a project-local copy of `cmd`
---found inside node_modules/.bin/, falling back to the system PATH.
---@param cmd string e.g. "prettier"
---@return fun(self: table, ctx: fmt.Context): string
M.from_node_modules = function(cmd) return M.find_executable({ "node_modules/.bin/" .. cmd }, cmd) end

---Return a command resolver that searches upward from the buffer's directory
---for each relative path in `paths`, returning the first executable found.
---Falls back to `default` (expected to be on $PATH).
---@param paths string[] Relative paths to search for, e.g. { "node_modules/.bin/prettier" }
---@param default string Fallback command name
---@return fun(self: table, ctx: fmt.Context): string
M.find_executable = function(paths, default)
    return function(self, ctx)
        for _, path in ipairs(paths) do
            local norm = vim.fs.normalize(path)

            -- Absolute path: check directly.
            if vim.startswith(norm, "/") then
                if vim.fn.executable(norm) == 1 then
                    return norm
                end
            else
                -- Relative path: walk upward looking for the first path segment.
                local slash = norm:find("/", 1, true)
                local dir = slash and norm:sub(1, slash - 1) or norm
                local sub = slash and norm:sub(slash) or ""
                for _, found in ipairs(vim.fs.find(dir, { upward = true, path = ctx.dirname, limit = math.huge })) do
                    local full = found .. sub
                    if vim.fn.executable(full) == 1 then
                        return full
                    end
                end
            end
        end
        return default
    end
end

---Return a cwd resolver that walks upward from the buffer's directory looking
---for any file in `files`. Used as the `cwd` field in formatter configs.
---@param files string|string[] File/directory names that mark the project root
---@return fun(self: table, ctx: fmt.Context): string|nil
M.root_file = function(files)
    return function(self, ctx) return vim.fs.root(ctx.dirname, files) end
end

---Slice a table from index `s` to index `e` (both inclusive, 1-based).
---@generic T
---@param tbl T[]
---@param s? integer Start index (default 1)
---@param e? integer End index (default #tbl)
---@return T[]
M.tbl_slice = function(tbl, s, e)
    local ret = {}
    for i = (s or 1), (e or #tbl) do
        ret[#ret + 1] = tbl[i]
    end
    return ret
end

---Return a new args function/value that prepends or appends `extra` to `args`.
---Both `args` and `extra` may be static tables/strings or functions
---(self, ctx) -> string|string[].
---@param args string|string[]|fun(self: table, ctx: fmt.Context): string|string[]
---@param extra string|string[]|fun(self: table, ctx: fmt.Context): string|string[]
---@param opts? { append?: boolean }  Default: prepend
---@return fun(self: table, ctx: fmt.Context): string|string[]
M.extend_args = function(args, extra, opts)
    opts = opts or {}
    return function(self, ctx)
        if type(args) == "function" then
            args = args(self, ctx)
        end
        if type(extra) == "function" then
            extra = extra(self, ctx)
        end

        if type(args) == "string" then
            if type(extra) ~= "string" then
                extra = table.concat(extra, " ")
            end
            return opts.append and (args .. " " .. extra) or (extra .. " " .. args)
        end

        assert(type(extra) ~= "string", "[fmt] extend_args: extra must be a table when args is a table")
        local ret = {}
        if opts.append then
            vim.list_extend(ret, args)
            vim.list_extend(ret, extra)
        else
            vim.list_extend(ret, extra)
            vim.list_extend(ret, args)
        end
        return ret
    end
end

---Mutate `formatter.args` (and `formatter.range_args` if present) to
---include `extra` args. Convenience wrapper around extend_args.
---@param formatter table
---@param extra string|string[]|fun(self: table, ctx: fmt.Context): string|string[]
---@param opts? { append?: boolean }
M.add_formatter_args = function(formatter, extra, opts) formatter.args = M.extend_args(formatter.args, extra, opts) end

---Deep-merge `override` onto `config`, then handle the special
---`prepend_args` / `append_args` keys that extend rather than replace args.
---@param config table Base formatter config
---@param override table Override table (from M.formatters[name])
---@return table
M.merge_formatter_configs = function(config, override)
    local ret = vim.tbl_deep_extend("force", config, override)
    if override.prepend_args then
        M.add_formatter_args(ret, override.prepend_args, { append = false })
    end
    if override.append_args then
        M.add_formatter_args(ret, override.append_args, { append = true })
    end
    return ret
end

---Parse the Rust edition from the nearest Cargo.toml above `dir`.
---Returns nil if not found or if the workspace inherits its edition.
---@param dir string Starting directory
---@return string|nil e.g. "2021"
M.parse_rust_edition = function(dir)
    for _, manifest in ipairs(vim.fs.find("Cargo.toml", { upward = true, path = dir, limit = math.huge })) do
        for line in io.lines(manifest) do
            -- Workspace-inherited edition: cannot be read from this file.
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

---Build an argv list suitable for vim.system() from a shell command string.
---Respects 'shell', 'shellcmdflag', and 'shellxquote' options.
---Only needed when a formatter's `args` is specified as a string rather
---than a table (the shell-string form).
---@param cmd string Complete shell command string
---@return string[]
M.shell_build_argv = function(cmd)
    local argv = {}

    -- Shell may be quoted if it contains spaces (see :h 'shell').
    if vim.startswith(vim.o.shell, '"') then
        local q = vim.o.shell:match('^"([^"]+)"')
        argv[#argv + 1] = q
        vim.list_extend(argv, vim.split(vim.o.shell:sub(q:len() + 3), "%s+", { trimempty = true }))
    else
        vim.list_extend(argv, vim.split(vim.o.shell, "%s+"))
    end

    vim.list_extend(argv, vim.split(vim.o.shellcmdflag, "%s+", { trimempty = true }))

    if vim.o.shellxquote ~= "" then
        if vim.o.shellxquote == "(" and vim.o.shellxescape ~= "" then
            cmd = cmd:gsub(".", function(c) return vim.o.shellxescape:find(c, 1, true) and "^" .. c or c end)
        end
        if vim.o.shellxquote == "(" then
            cmd = "(" .. cmd .. ")"
        elseif vim.o.shellxquote == '"(' then
            cmd = '"(' .. cmd .. ')"'
        else
            cmd = vim.o.shellxquote .. cmd .. vim.o.shellxquote
        end
    end

    argv[#argv + 1] = cmd
    return argv
end

---Return the line ending string for a buffer based on its 'fileformat'.
---@param bufnr integer
---@return string "\n", "\r\n", or "\r"
M.buf_line_ending = function(bufnr)
    local ff = vim.bo[bufnr].fileformat
    return ff == "dos" and "\r\n" or ff == "mac" and "\r" or "\n"
end

return M
