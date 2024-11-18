return {
	{
		"hrsh7th/cmp-vsnip",
		dependencies = {
			"hrsh7th/vim-vsnip",
			"rafamadriz/friendly-snippets",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			local cmp = require("cmp")
			local function has_words_before()
				local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end
			local function is_visible(cmp)
				return cmp.core.view:visible() or vim.fn.pumvisible() == 1
			end

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
			cmp.setup({
				snippet = {
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},

				formatting = {
					format = function(entry, vim_item)
						if vim.tbl_contains({ "path" }, entry.source.name) then
							local icon, hl_group =
								require("nvim-web-devicons").get_icon(entry:get_completion_item().label)
							if icon then
								vim_item.kind = icon
								vim_item.kind_hl_group = hl_group
								return vim_item
							end
						end
						return require("lspkind").cmp_format({ with_text = false })(entry, vim_item)
					end,
				},

				preselect = cmp.PreselectMode.None,
				confirm_opts = {
					behavior = cmp.ConfirmBehavior.Replace,
					select = false,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				mapping = {
					["<Up>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
					["<Down>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
					["<C-P>"] = cmp.mapping(function()
						if is_visible(cmp) then
							cmp.select_prev_item()
						else
							cmp.complete()
						end
					end),
					["<C-N>"] = cmp.mapping(function()
						if is_visible(cmp) then
							cmp.select_next_item()
						else
							cmp.complete()
						end
					end),
					["<C-K>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
					["<C-J>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
					["<C-U>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-D>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-Y>"] = cmp.config.disable,
					["<C-E>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
					["<CR>"] = cmp.mapping(cmp.mapping.confirm({ select = false }), { "i", "c" }),
					["<Tab>"] = cmp.mapping(function(fallback)
						if is_visible(cmp) then
							cmp.select_next_item()
						elseif
							vim.api.nvim_get_mode().mode ~= "c"
							and vim.snippet
							and vim.snippet.active({ direction = 1 })
						then
							vim.schedule(function()
								vim.snippet.jump(1)
							end)
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if is_visible(cmp) then
							cmp.select_prev_item()
						elseif
							vim.api.nvim_get_mode().mode ~= "c"
							and vim.snippet
							and vim.snippet.active({ direction = -1 })
						then
							vim.schedule(function()
								vim.snippet.jump(-1)
							end)
						else
							fallback()
						end
					end, { "i", "s" }),
				},

				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
					{ name = "nvim_lua" },
					{
						name = "path",
						option = {
							trailing_slash = false,
							label_trailing_slash = false,
						},
					},
				}, { { name = "buffer" } }),
			})
		end,
	},
}
