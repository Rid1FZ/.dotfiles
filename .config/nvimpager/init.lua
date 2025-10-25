local options = require("options")
local mappings = require("mappings")
local configs = require("configs")

--------------------------------------------------------------------
-- Setup options
--------------------------------------------------------------------
options.setup()

--------------------------------------------------------------------
-- Setup lazy.nvim
--------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv
local log_levels = vim.log.levels

if not uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.notify("Bootstrapping lazy.nvim...", log_levels.INFO)

    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.notify(string.format("Failed to load lazy.nvim:\n\n%s", out), log_levels.ERROR)
        vim.notify("Press any key to continue...", log_levels.INFO)
        vim.fn.getchar()
        os.exit(1)
    else
        vim.notify("Done...", log_levels.INFO)
    end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup(require("configs.lazy"))

--------------------------------------------------------------------
-- Setup autocommands
--------------------------------------------------------------------
pcall(configs.setup_autocommands)

--------------------------------------------------------------------
-- Setup keymappings
--------------------------------------------------------------------
mappings.setup()
