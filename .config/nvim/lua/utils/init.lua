local M = {}

local merge_tb = vim.tbl_deep_extend
local contains = vim.tbl_contains
local api = vim.api
local log_levels = vim.log.levels
local notify = vim.notify

M.highlight = function(name, val)
    api.nvim_set_hl(0, name, val)
end

M.start_treesitter = function()
    local filetype = vim.bo.filetype
    local nvim_treesitter = require("nvim-treesitter")

    if not contains(nvim_treesitter.get_installed(), filetype) then
        if contains(nvim_treesitter.get_available(), filetype) then
            notify(string.format("installing '%s' treesitter parser...", filetype), log_levels.INFO)
            nvim_treesitter.install(filetype):wait(30000)
        end
    end

    vim.treesitter.start()
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

M.load_mappings = function(section, mapping_opt)
    vim.schedule(function()
        local function set_section_map(section_values)
            if section_values.plugin then
                return
            end

            section_values.plugin = nil

            for mode, mode_values in pairs(section_values) do
                local default_opts = merge_tb("force", { mode = mode }, mapping_opt or {})
                for keybind, mapping_info in pairs(mode_values) do
                    -- merge default + user opts
                    local opts = merge_tb("force", default_opts, mapping_info.opts or {})

                    mapping_info.opts, opts.mode = nil, nil
                    opts.desc = mapping_info[2]

                    vim.keymap.set(mode, keybind, mapping_info[1], opts)
                end
            end
        end

        local mappings = require("mappings")

        if type(section) == "string" then
            mappings[section]["plugin"] = nil
            mappings = { mappings[section] }
        end

        for _, sect in pairs(mappings) do
            set_section_map(sect)
        end
    end)
end

return M
