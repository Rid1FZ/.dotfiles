return {
	"nvim-tree/nvim-tree.lua",
	cmd = { "NvimTreeToggle", "NvimTreeFocus" },
	init = function()
		require("utils").load_mappings("nvimtree")
	end,
	opts = function()
		return require("configs.nvim-tree")
	end,
	config = function(_, opts)
		require("nvim-tree").setup(opts)
	end,
}
