return {
	"alexghergh/nvim-tmux-navigation",
	event = "VeryLazy",

	config = function()
		require("nvim-tmux-navigation").setup({})

		vim.keymap.set("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { desc = "Window left" })
		vim.keymap.set("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { desc = "Window down" })
		vim.keymap.set("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { desc = "Window up" })
		vim.keymap.set("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { desc = "Window right" })
	end,
}
