return {
	debounce = 100,
	whitespace = { highlight = { "Whitespace", "NonText" } },
	exclude = {
		filetypes = {
			"help",
			"terminal",
			"lazy",
			"lspinfo",
			"TelescopePrompt",
			"TelescopeResults",
			"mason",
			"",
		},
		buftypes = { "terminal" },
	},
	scope = {
		enabled = true,
		show_start = false,
		show_end = false,
	},
}
