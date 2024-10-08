---@type LazySpec
return {
	{
		"williamboman/mason-lspconfig.nvim",
		opts = function(_, opts)
			opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
				"lua_ls",
				"pyright",
				"clangd",
				"jsonls",
				"rust_analyzer",
			})
		end,
	},
	{
		"jay-babu/mason-null-ls.nvim",
		opts = function(_, opts)
			opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
				"prettier",
				"stylua",
				"black",
				"isort",
			})
		end,
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		opts = function(_, opts)
			opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {})
		end,
	},
}
