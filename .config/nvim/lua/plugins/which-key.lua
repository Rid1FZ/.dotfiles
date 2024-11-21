return {
	"folke/which-key.nvim",
	event = "VimEnter",
	init = function()
		require("utils").load_mappings("whichkey")
	end,
	config = function(_, opts)
		require("which-key").setup(opts)
		require("configs.which-key")
	end,
}
