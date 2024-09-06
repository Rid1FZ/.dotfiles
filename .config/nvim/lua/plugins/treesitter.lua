---@type LazySpec
return {
	"nvim-treesitter/nvim-treesitter",
	opts = function(_, opts)
		opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
			"lua",
			"vim",
			"hyprlang",
			"python",
			"bash",
			"c",
			"cpp",
			"yaml",
			"toml",
			"json",
			"jsonc",
			"git_config",
			"gitignore",
			"gitcommit",
			"css",
			"zathurarc",
		})
	end,
}
