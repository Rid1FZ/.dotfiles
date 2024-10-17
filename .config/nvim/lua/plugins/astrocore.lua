---@type LazySpec
return {
	"AstroNvim/astrocore",
	---@type AstroCoreOpts
	opts = {
		features = {
			large_buf = { size = 1024 * 500, lines = 10000 },
			autopairs = true,
			cmp = true,
			diagnostics_mode = 2,
			highlighturl = true,
			notifications = true,
		},
		diagnostics = {
			virtual_text = false,
			underline = true,
		},
		options = {
			-- neovim options
			opt = {
				relativenumber = true,
				number = true,
				spell = false,
				signcolumn = "yes:1",
				wrap = false,
				mouse = "nv",
				mousemodel = "extend",
				swapfile = false,
				cmdheight = 1,
			},

			-- global variables
			g = {
				autoformat_enabled = true,
				cmp_enabled = true,
				autopairs_enabled = true,
				diagnostics_mode = 3,
				icons_enabled = true,
				ui_notifications_enabled = true,
				neovide_cursor_animation_length = 0,
				neovide_scroll_animation_length = 0,
			},
		},
		-- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
		mappings = {
			-- normal mode
			n = {
				["<Leader>fb"] = { "<cmd>Telescope buffers initial_mode=normal<cr>", desc = "Search buffers" },
			},

			-- terminal mode
			t = {},

			-- insert mode
			i = {},
		},
	},
}
