return {
	"nvim-telescope/telescope.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	cmd = "Telescope",
	init = function()
		require("utils").load_mappings("telescope")
	end,
	opts = function()
		return require("configs.telescope")
	end,
}
