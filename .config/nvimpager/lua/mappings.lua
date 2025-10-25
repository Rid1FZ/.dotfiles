local M = {}

local api = vim.api
local set_keymap = vim.keymap.set

-- nvimpager uses `BufEnter` event to trigger a function which sets up all
-- the keybindings. So to override default keybindings, use `vim.defer_fn`
-- to wait until everything is done, then set the mappings
M.setup = function()
    api.nvim_create_autocmd("BufEnter", {
        group = api.nvim_create_augroup("RunAfterAll", { clear = true }),
        callback = function()
            vim.defer_fn(function()
                set_keymap("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { desc = "Window left" })
                set_keymap("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { desc = "Window down" })
                set_keymap("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { desc = "Window up" })
                set_keymap("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { desc = "Window right" })

                set_keymap("n", "<Esc>", "<Cmd>nohl<CR>", { buffer = true })
                set_keymap({ "n", "v" }, "q", "<Cmd>quit!<CR>", { buffer = true })
                set_keymap("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, buffer = true })
                set_keymap("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, buffer = true })
                set_keymap("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, buffer = true })
                set_keymap("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, buffer = true })
            end, 10)
        end,
    })
end

return M
