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

-- Setup options and mappings
options.setup()
utils.load_mappings()

-- Bootstrap Lazy.nvim safely
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv

if not uv.fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.notify("Bootstrapping lazy.nvim...", vim.log.levels.INFO)

    local ok = os.execute(string.format("git clone --filter=blob:none --branch=stable %s %s", repo, lazypath))
    if ok ~= 0 then
        vim.notify("Failed to clone lazy.nvim! Please check your internet connection.", vim.log.levels.ERROR)
        return
    end
end

vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup(require("configs.lazy"))

-- Setup diagnostics and LSP
lspconfig.configure_diagnostics()
lspconfig.setup()

-- Setup completions (after LSP to attach properly)
pcall(completions.setup)

-- Setup statusline (isolated in case of FZF memory leak)
local ok_status, err = pcall(statusline.setup)
if not ok_status then
    vim.notify("Statusline setup failed: " .. tostring(err), vim.log.levels.WARN)
end

-- Setup autocommands last
pcall(configs.setup_autocommands)
