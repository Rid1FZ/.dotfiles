return {
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		cmd = "Telescope",
		ft = "mason",
		init = function()
			require("utils").load_mappings("telescope")
		end,
		opts = function()
			return require("configs.telescope")
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
