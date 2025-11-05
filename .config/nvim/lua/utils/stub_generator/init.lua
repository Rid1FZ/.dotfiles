local M = {}

local local_utils = require("utils.stub_generator.utils")
local collectors = require("utils.stub_generator.collectors")

local fn = vim.fn
local api = vim.api

local function make_header()
    return table.concat({
        "-- neovim builtins stub (generated)",
        "-- For LSP indexing only. Do NOT require/source at runtime.",
        "---@meta",
        "---@diagnostic disable: duplicate-set-field, undefined-field, missing-parameter, unused-local, undefined-global",
        "",
    }, "\n")
end

local function make_prelude()
    return table.concat({
        "vim = vim or {}",
        "vim.fn = vim.fn or {}",
        "vim.api = vim.api or {}",
        "vim.opt = vim.opt or {}",
        "vim.o = vim.o or {}",
        "vim.g = vim.g or {}",
        "vim.bo = vim.bo or {}",
        "vim.wo = vim.wo or {}",
        "vim.b = vim.b or {}",
        "vim.w = vim.w or {}",
        "vim.t = vim.t or {}",
        "vim.keymap = vim.keymap or {}",
        "vim.inspect = vim.inspect or function(...) end",
        "vim.loop = vim.loop or {}",
        "",
    }, "\n")
end

local function write_stubs_file(outdir, filename, collectors_)
    local_utils.mkdir_p(outdir)

    local fpath = outdir .. "/" .. filename
    local f, err = io.open(fpath, "w")
    if not f then
        return nil, ("failed to open %s: %s"):format(fpath, tostring(err))
    end

    f:write(make_header())
    f:write("\n")
    f:write(make_prelude())

    f:write("\n-- vim.fn stubs\n")
    for _, name in ipairs(collectors_.vim_fn) do
        f:write(("function vim.fn['%s'](...) end\n"):format(name:gsub("'", "\\'")))
    end

    f:write("\n-- vim.api stubs\n")
    for _, name in ipairs(collectors_.vim_api) do
        f:write(("function vim.api['%s'](...) end\n"):format(name:gsub("'", "\\'")))
    end

    f:write("\n-- top-level vim fields (declared as tables/values)\n")
    for _, name in ipairs(collectors_.vim_fields) do
        if
            name ~= "fn"
            and name ~= "api"
            and name ~= "opt"
            and name ~= "o"
            and name ~= "g"
            and name ~= "bo"
            and name ~= "wo"
            and name ~= "b"
            and name ~= "w"
            and name ~= "t"
            and name ~= "keymap"
            and name ~= "inspect"
            and name ~= "loop"
        then
            if local_utils.is_identifier(name) then
                f:write(("vim.%s = vim.%s or {}\n"):format(name, name))
            else
                f:write(("vim['%s'] = vim['%s'] or {}\n"):format(name, name))
            end
        end
    end

    f:write("\n-- option stubs (vim.o / vim.opt)\n")
    for _, name in ipairs(collectors_.options) do
        if local_utils.is_identifier(name) then
            f:write(("vim.o.%s = vim.o.%s or nil\n"):format(name, name))
            f:write(("vim.opt.%s = vim.opt.%s or nil\n"):format(name, name))
        else
            f:write(("vim.o['%s'] = vim.o['%s'] or nil\n"):format(name, name))
            f:write(("vim.opt['%s'] = vim.opt['%s'] or nil\n"):format(name, name))
        end
    end

    f:close()
    return fpath, nil
end

M.generate = function(outdir)
    outdir = outdir or (fn.stdpath("data") .. "/lua_ls_stubs")
    local collectors_ = {
        vim_fn = collectors.collect_vim_fn(),
        vim_api = collectors.collect_vim_api(),
        vim_fields = collectors.collect_vim_fields(),
        options = collectors.collect_options(),
    }

    local fname = "neovim_builtins.lua"
    local fpath, err = write_stubs_file(outdir, fname, collectors_)
    if not fpath then
        vim.notify("GenerateNeovimStubs: failed: " .. tostring(err), vim.log.levels.ERROR)
        return
    end

    vim.notify("GenerateNeovimStubs: wrote stubs to " .. fpath .. " (for LSP indexing)", vim.log.levels.INFO)

    return fpath
end

M.setup_command = function()
    api.nvim_create_user_command("GenerateNeovimStubs", function(opts)
        local out = nil

        if opts.args and #opts.args > 0 then
            out = M.generate(opts.args)
        else
            out = M.generate()
        end

        if out then
            print("Neovim LSP stubs written to: " .. out)
        end
    end, { nargs = "?" })
end

return M
