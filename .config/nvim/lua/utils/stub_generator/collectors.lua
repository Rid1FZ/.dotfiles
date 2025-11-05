local M = {}

local local_utils = require("utils.stub_generator.utils")

local options = {
    opt = {},
    opt_global = {},
    opt_local = {},
    bo = {},
    wo = {},
}

local fn = vim.fn
local api = vim.api

M.collect_vim_fn = function()
    local ok, list = pcall(fn.getcompletion, "", "function")

    if not ok or type(list) ~= "table" then
        return {}
    end

    return local_utils.uniq_sorted(list)
end

M.collect_vim_api = function()
    return local_utils.uniq_sorted(local_utils.safe_pairs_of_table(vim.api))
end

M.collect_vim_fields = function()
    return local_utils.uniq_sorted(local_utils.safe_pairs_of_table(vim))
end

local collect_options = function()
    local ok, opts_info = pcall(api.nvim_get_all_options_info)

    if not ok or type(opts_info) ~= "table" then
        return {}
    end

    for name, info in pairs(opts_info) do
        table.insert(options.opt, name)

        if info.scope == "global" then
            table.insert(options.opt_global, name)
        elseif info.scope == "buf" then
            table.insert(options.opt_local, name)
            table.insert(options.bo, name)
        elseif info.scope == "win" then
            table.insert(options.opt_local, name)
            table.insert(options.bo, name)
        end
    end

    return local_utils.uniq_sorted(options.opt)
end

return M
