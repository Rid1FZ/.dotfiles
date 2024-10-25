vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		require("lsp_signature").on_attach({
			hint_enable = false,
			hint_prefix = "",
			doc_lines = 0,
			handler_opts = {
				border = "rounded",
			},
		})
	end,
})
