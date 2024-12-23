return {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonUninstallAll" },

    opts = function()
        return require("configs.plugins.mason")
    end,

    config = function(_, opts)
        require("mason").setup(opts)
    end,
}
