---@class Utils
local M = {}

local merge_tb = vim.tbl_deep_extend
local contains = vim.tbl_contains
local wo = vim.wo -- always use the index form: wo[something]
local bo = vim.bo -- always use the index form: bo[something]
local api = vim.api
local log_levels = vim.log.levels
local notify = vim.notify
local treesitter = vim.treesitter
local keymap = vim.keymap
local schedule = vim.schedule
local format = string.format

--------------------------------------------------------------------
-- Set highlighting
--------------------------------------------------------------------
---@param name string The highlight group name
---@param val vim.api.keyset.highlight The highlight attributes
---@return nil
M.highlight = function(name, val)
    api.nvim_set_hl(0, name, val)
end

--------------------------------------------------------------------
-- Start treesitter for current buffer
--------------------------------------------------------------------
---@param bufnr integer Buffer number
---@param winnr integer Window number
---@return nil
M.start_treesitter = function(bufnr, winnr)
    local filetype = bo[bufnr].filetype
    local parser_available, _ = pcall(treesitter.get_parser, bufnr) -- NOTE: change this in Neovim 0.12

    if not parser_available then
        local nvim_treesitter = require("nvim-treesitter") -- do not require unless needed
        if not contains(nvim_treesitter.get_available(), filetype) then
            return
        end

        notify(format("installing '%s' treesitter parser...", filetype), log_levels.INFO)
        nvim_treesitter.install(filetype):wait(30000)
    end

    treesitter.start(bufnr)
    wo[winnr].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

--------------------------------------------------------------------
-- Load keymappings for specific plugin
--------------------------------------------------------------------
---@param section? string|table Optional mapping section name or table
---@param mapping_opt? table Optional mapping options
---@return nil
M.load_mappings = function(section, mapping_opt)
    schedule(function()
        ---@param section_values table
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

                    keymap.set(mode, keybind, mapping_info[1], opts)
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
