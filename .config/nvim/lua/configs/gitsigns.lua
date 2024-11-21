return {
	signs = {
		add = { text = "│" },
		change = { text = "│" },
		delete = { text = "󰍵" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
		untracked = { text = "│" },
	},
	on_attach = function(bufnr)
		require("utils").load_mappings("gitsigns", { buffer = bufnr })
	end,
}
