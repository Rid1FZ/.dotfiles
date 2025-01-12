-- Setup Options and Keymappings
require("options")
require("utils").load_mappings()

-- Setup Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"

    vim.api.nvim_echo({
        { "*** Bootstrapping lazy.nvim... ***" },
    }, true, {})
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })

    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    else
        vim.api.nvim_echo({
            { "Done..." },
        }, true, {})
    end
end

vim.opt.rtp:prepend(lazypath)
require("lazy").setup(require("configs.lazy"))

-- Setup Autocommands
require("autocommands")
