return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	config = function()
		require("ibl").setup({
			debounce = 100,
			whitespace = { highlight = { "Whitespace", "NonText" } },
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
			},
		})
	end,
}
