----------------------------------------------
-- register treesitter grammer for filetype --
----------------------------------------------
vim.treesitter.language.register("bash", "zsh")

-------------------
-- add filetypes --
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
	},
})

---------------------------------------------
-- add commentstring for specific filetype --
---------------------------------------------
vim.api.nvim_create_augroup("set_commentstring", { clear = true })

local cstrings = {
	hyprlang = "#%s",
	qml = "//%s",
}

for lang, cstring in pairs(cstrings) do
	vim.api.nvim_create_autocmd("FileType", {
		group = "set_commentstring",
		pattern = lang,
		command = [[set commentstring=]] .. cstring,
	})
end
