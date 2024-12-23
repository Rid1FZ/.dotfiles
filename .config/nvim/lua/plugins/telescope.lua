return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        ft = "mason",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope-ui-select.nvim",
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = "make",
            },
        },

        init = function()
            require("utils").load_mappings("telescope")
        end,

        opts = function()
            return require("configs.plugins.telescope")
        end,

        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)

            -- load extensions
            if opts.extensions then
                for extension, _ in pairs(opts.extensions) do
                    telescope.load_extension(extension)
                end
            end
        end,
    },
}
