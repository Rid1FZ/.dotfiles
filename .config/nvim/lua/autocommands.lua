---------------------------
-- Trigger lsp_signature --
---------------------------
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		require("lsp_signature").on_attach({
			hint_enable = false,
			hint_prefix = "",
			doc_lines = 0,
			handler_opts = {
				border = "rounded",
			},
		})
	end,
})

-----------------------------------
-- Close NvimTree if Last Window --
-----------------------------------
vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		local invalid_win = {}
		local wins = vim.api.nvim_list_wins()
		for _, w in ipairs(wins) do
			local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
			if bufname:match("NvimTree_") ~= nil then
				table.insert(invalid_win, w)
			end
		end
		if #invalid_win == #wins - 1 then
			-- Should quit, so we close all invalid windows.
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

-------------------------------------------------------
-- Open nvim-tree if Neovim is Opened With Directory --
-------------------------------------------------------
vim.api.nvim_create_autocmd({ "VimEnter" }, {
	callback = function(data)
		if not (vim.fn.isdirectory(data.file) == 1) then
			return
		end

		vim.cmd.cd(data.file)
		require("nvim-tree.api").tree.open({
			current_window = false,
		})
	end,
})
