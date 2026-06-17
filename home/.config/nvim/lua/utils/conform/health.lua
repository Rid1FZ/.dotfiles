local M = {}

M.check = function()
    local h = vim.health
    local fn = vim.fn
    local fs = vim.fs

    --------------------------------------------------------------------
    -- Section 1: formatters directory
    --------------------------------------------------------------------
    h.start("Formatters directory")

    local dir = fn.stdpath("config") .. "/lua/configs/formatters"

    if fn.isdirectory(dir) == 0 then
        h.error("Directory not found: `" .. dir .. "`", { "Create the directory and add formatter config files to it" })
        return
    end

    h.ok("`" .. dir .. "`")

    --------------------------------------------------------------------
    -- Helpers
    --------------------------------------------------------------------

    ---Format a root_markers value into a compact readable string.
    ---@param markers (string|string[])[]
    ---@return string
    local function fmt_markers(markers)
        local parts = {}
        for _, m in ipairs(markers) do
            if type(m) == "table" then
                local inner = {}
                for _, v in ipairs(m) do
                    inner[#inner + 1] = '"' .. v .. '"'
                end
                parts[#parts + 1] = "{ " .. table.concat(inner, " | ") .. " }"
            else
                parts[#parts + 1] = '"' .. m .. '"'
            end
        end
        return table.concat(parts, ", ")
    end

    --------------------------------------------------------------------
    -- Section 2: individual formatter configs
    --------------------------------------------------------------------
    h.start("Formatters")

    ---@type string[]
    local names = {}
    for entry, kind in fs.dir(dir) do
        if kind == "file" then
            local name = entry:match("^(.-)%.lua$")
            if name then
                names[#names + 1] = name
            end
        end
    end

    if #names == 0 then
        h.warn("No formatter configs found in `" .. dir .. "`")
        return
    end

    table.sort(names)

    for _, name in ipairs(names) do
        local ok, config = pcall(require, "configs.formatters." .. name)
        if not ok then
            h.error(("`%s` · failed to load config"):format(name), { tostring(config) })
            goto continue
        end

        local fts = type(config.filetype) == "string" and config.filetype or table.concat(config.filetype or {}, ", ")

        local cwd_suffix
        if config.root_markers then
            cwd_suffix = "root: " .. fmt_markers(config.root_markers)
        elseif type(config.cwd) == "function" then
            cwd_suffix = "cwd: (function)"
        end

        if type(config.command) == "function" then
            local msg = ("`%s` [%s] · command: (function)"):format(name, fts)
            if cwd_suffix then
                msg = msg .. " · " .. cwd_suffix
            end
            h.info(msg)
        else
            local cmd = config.command
            local resolved = fn.exepath(cmd)

            if resolved ~= "" then
                local msg = ("`%s` [%s] · `%s`"):format(name, fts, resolved)
                if cwd_suffix then
                    msg = msg .. " · " .. cwd_suffix
                    h.ok(msg)
                else
                    h.warn(msg, { "Add `root_markers` to pin the formatter's cwd to the project root" })
                end
            else
                local advice = {
                    ("Install `%s` or remove `%s.lua` from the formatters directory"):format(cmd, name),
                }
                if cwd_suffix then
                    advice[#advice + 1] = cwd_suffix
                end
                h.error(("`%s` [%s] · executable `%s` not found"):format(name, fts, cmd), advice)
            end
        end

        ::continue::
    end
end

return M
