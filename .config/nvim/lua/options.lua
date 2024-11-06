-------------
-- Options --
-------------
vim.g.mapleader = " "
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.swapfile = false
vim.opt.signcolumn = "yes:2"
vim.opt.confirm = true
vim.opt.wrap = false
vim.opt.clipboard = "unnamedplus"
vim.wo.number = true
vim.wo.relativenumber = true
vim.g.background = "dark"
vim.opt.shortmess = vim.opt.shortmess + {
	c = true,
	F = true,
	W = true,
	I = true,
}

-------------------------
-- LSP and Diagnostics --
-------------------------
local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config({
	signs = {
		active = signs, -- show signs
	},
	update_in_insert = true,
	underline = true,
	virtual_text = false,
	severity_sort = true,
	float = {
		focusable = true,
		style = "minimal",
		border = "single",
		source = "always",
		header = "Diagnostic",
		prefix = "",
	},
})

-------------------
-- Add Filetypes --
-------------------
vim.filetype.add({
	extension = {
		qml = "qml",
		ipy = "python",
	},
	pattern = {
		["/home/.*/.config/hypr/.*.conf"] = "hyprlang",
		[".*/hyperland/.*.conf"] = "hyprlang",
		["/home/.*/.config/waybar/config"] = "jsonc",
		["/home/.*/.config/zathura/.*"] = "zathurarc",
		["/home/.*/.config/tmux/configs/.*.tmux"] = "tmux",
	},
})

---------------------------------
-- Register TreeSitter Grammer --
---------------------------------
vim.treesitter.language.register("bash", "zsh")
