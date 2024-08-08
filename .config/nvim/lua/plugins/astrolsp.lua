---@type LazySpec
return {
	"AstroNvim/astrolsp",
	---@type AstroLSPOpts
	opts = {
		features = {
			autoformat = true,
			codelens = true,
			inlay_hints = false,
			semantic_tokens = true,
		},
		formatting = {
			format_on_save = {
				enabled = true,
				allow_filetypes = {},
				ignore_filetypes = {},
			},
			disabled = {
				"lua_ls",
				"pyright",
			},
			timeout_ms = 60000,
			filter = function(client)
				return true
			end,
		},
		servers = {},
		---@diagnostic disable: missing-fields
		config = {
			clangd = { capabilities = { offsetEncoding = "utf-8" } },
			rust_analyzer = {
				settings = {
					["rust-analyzer"] = {
						cargo = {
							features = "all",
						},
					},
				},
			},
		},
		handlers = {},
		autocmds = {
			-- :h augroup
			lsp_document_highlight = {
				cond = "textDocument/documentHighlight",
				{
					event = { "CursorHold", "CursorHoldI" },
					--:h nvim_create_autocmd
					desc = "Document Highlighting",
					callback = function()
						vim.lsp.buf.document_highlight()
					end,
				},
				{
					event = { "CursorMoved", "CursorMovedI", "BufLeave" },
					desc = "Document Highlighting Clear",
					callback = function()
						vim.lsp.buf.clear_references()
					end,
				},
			},
		},
		mappings = {
			n = {
				gl = {
					function()
						vim.diagnostic.open_float()
					end,
					desc = "Hover diagnostics",
				},
			},
		},
		-- :h lspconfig-setup
		on_attach = function(client, bufnr) end,
	},
}
