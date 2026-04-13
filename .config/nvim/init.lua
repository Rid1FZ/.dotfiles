-- Enable bytecode cache for faster module loading (Neovim 0.11+)
vim.loader.enable()

-- Prevent reloading twice
if vim.g.loaded_config_init then
    return
end
vim.g.loaded_config_init = true

local utils = require("utils")
local options = require("options")
local configs = require("configs")
local lspconfig = require("configs.lsp")
local completions = require("utils.completions")
local statusline = require("utils.statusline")

local notify = vim.notify
local log_levels = vim.log.levels
local uv = vim.uv
local fn = vim.fn

--------------------------------------------------------------------
-- Setup options
--------------------------------------------------------------------
options.setup()

--------------------------------------------------------------------
-- Setup keymappings
--------------------------------------------------------------------
utils.load_mappings()

--------------------------------------------------------------------
-- Setup lsp and diagnostics
--------------------------------------------------------------------
lspconfig.configure_diagnostics()
lspconfig.setup()

--------------------------------------------------------------------
-- Setup autocompletion
--------------------------------------------------------------------
pcall(completions.setup)

--------------------------------------------------------------------
-- Setup statusline
--------------------------------------------------------------------
local ok_status, err = pcall(statusline.setup)
if not ok_status then
    notify("Statusline setup failed: " .. tostring(err), log_levels.WARN)
end

--------------------------------------------------------------------
-- Setup autocommands
--------------------------------------------------------------------
pcall(configs.setup_custom_events)
pcall(configs.setup_autocommands)
