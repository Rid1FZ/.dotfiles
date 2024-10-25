---------------
-- Variables --
---------------
local wk = require("which-key")
local tbuiltin = require("telescope.builtin")

----------------------------
-- Using which-key Plugin --
----------------------------
wk.add({
	{
		mode = { "n" },
		{
			"<Leader>o",
			group = "Open",
			icon = "󰮰 ",
			{
				{ "<Leader>oe", "<cmd>Neotree<cr>", desc = "Open Explorer", icon = " " },
			},
		},
		{
			"<Leader>b",
			group = "Buffer",
			icon = " ",
			{
				{ "<Leader>bc", "<cmd>bdelete<cr>", desc = "Close Current Buffer", icon = "󰅗 " },
			},
		},
		{
			"<Leader>f",
			group = "Find",
			icon = " ",
			{
				{ "<Leader>fb", tbuiltin.buffers, desc = "Find Buffer", icon = "󰓩 " },
				{ "<Leader>ff", tbuiltin.find_files, desc = "Find Files", icon = " " },
				{ "<Leader>fg", tbuiltin.live_grep, desc = "Live Grep", icon = " " },
				{ "<Leader>fo", tbuiltin.oldfiles, desc = "Old Files", icon = " " },
			},
		},
		{
			"g",
			icon = "󰮰 ",
			{
				{ "gd", vim.lsp.buf.definition, desc = "Goto definition", icon = " " },
				{ "gr", vim.lsp.buf.references, desc = "Goto reference", icon = " " },
			},
		},
		{
			"<Leader>l",
			group = "LSP",
			icon = " ",
			{
				{ "<Leader>ld", vim.diagnostic.open_float, desc = "Hover Diagnostic", icon = " " },
				{ "<Leader>la", vim.lsp.buf.code_action, desc = "Code Actions", icon = "󰁨 " },
			},
		},
		{ "<Leader>q", "<cmd>quitall<cr>", desc = "Quit Neovim", icon = "󰈆 " },
		{ "<Leader>w", "<cmd>write<cr>", desc = "Write File", icon = " " },
		{ "<Leader>h", "<cmd>nohlsearch<cr>", desc = "Stop Highlighting", icon = "󰝷 " },
	},
})

------------------------------
-- Without which-key Plugin --
------------------------------
vim.keymap.set("n", "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>")
