return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = " ",
						package_pending = " ",
						package_uninstalled = " ",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = true,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua_ls",
					"stylua",
					"pyright",
					"black",
					"isort",
					"mypy",
					"shfmt",
					"shellcheck",
					"bashls",
					"clangd",
					"clang-format",
				},
			})
		end,
	},
}
