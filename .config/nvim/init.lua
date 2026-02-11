-- Enable bytecode cache for faster module loading (Neovim 0.11+)
if vim.loader and not vim.loader.enabled then
    vim.loader.enable()
end

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
-- Bootstrap lazy.nvim
--------------------------------------------------------------------
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    notify("Bootstrapping lazy.nvim...", log_levels.INFO)

    local out = fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        notify(string.format("Failed to load lazy.nvim:\n\n%s", out), log_levels.ERROR)
        notify("Press any key to continue...", log_levels.INFO)
        fn.getchar()
        os.exit(1)
    else
        notify("Done...", log_levels.INFO)
    end
end

vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup(require("configs.lazy"))

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
