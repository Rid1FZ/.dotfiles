return {
	ensure_installed = {
		"lua-language-server",
		"stylua",
		"pyright",
		"black",
		"isort",
		"mypy",
		"shfmt",
		"shellcheck",
		"bash-language-server",
		"clangd",
		"clang-format",
	},

	PATH = "skip",

	ui = {
		icons = {
			package_pending = " ",
			package_installed = "󰄳 ",
			package_uninstalled = " 󰚌",
		},
	},

	max_concurrent_installers = 10,
}
