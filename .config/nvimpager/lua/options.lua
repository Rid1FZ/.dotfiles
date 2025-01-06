local opt = vim.opt

opt.laststatus = 0
opt.showtabline = 0
opt.showmode = false

opt.clipboard = "unnamedplus"
opt.cursorline = false
opt.scrolloff = 99999

-- Indenting
opt.expandtab = true
opt.shiftwidth = 4
opt.smartindent = true
opt.tabstop = 4
opt.softtabstop = 4

opt.fillchars = { eob = " " }
opt.ignorecase = true
opt.smartcase = true
opt.mouse = "a"

-- Numbers
opt.number = false
opt.relativenumber = false
opt.ruler = false
opt.shortmess = opt.shortmess + {
	s = true,
	c = true,
	F = true,
	W = true,
	I = true,
	l = true,
}

opt.signcolumn = "no"
opt.splitbelow = true
opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400
opt.wrap = false
opt.pumheight = 10

-- Disable Right Click Menu
vim.cmd([[aunmenu PopUp]])

-- Add Filetypes
vim.filetype.add({
	extension = {
		qml = "qml",
		ipy = "python",
		sh = "bash",
		bash = "bash",
	},
	pattern = {
		["/home/.*/.config/hypr/.*.conf"] = "hyprlang",
		[".*/hyperland/.*.conf"] = "hyprlang",
		["/home/.*/.config/waybar/config"] = "jsonc",
		["/home/.*/.config/zathura/.*"] = "zathurarc",
		["/home/.*/.config/tmux/configs/.*.tmux"] = "tmux",
	},
})

-- register grammers
vim.treesitter.language.register("bash", "zsh")
