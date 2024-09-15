return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		filesystem = {
			hijack_netrw_behavior = "open_default",
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignore = false,
				never_show = {
					".git",
					"__pycache__",
					".mypy_cache",
				},
			},
		},
		window = {
			mappings = {
				["a"] = "add",
				["A"] = "add_directory",
			},
		},
	},
}
