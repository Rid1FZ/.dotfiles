return {
	"folke/which-key.nvim",
	keys = { "<leader>", "<c-r>", "<c-w>", '"', "'", "`", "c", "v", "g" },
	init = function()
		require("utils").load_mappings("whichkey")
	end,
	cmd = "WhichKey",
	config = function(_, opts)
		require("which-key").setup(opts)
		require("configs.which-key")
	end,
}
