-- nvimpager uses `BufEnter` event to trigger a function which sets up all
-- the keybindings. So to override default keybindings, use `vim.defer_fn`
-- to wait until everything is done, then set the mappings
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("RunAfterAll", { clear = true }),
    callback = function()
        vim.defer_fn(function()
            vim.keymap.set("n", "<Esc>", "<Cmd>nohl<CR>", { buffer = true })
            vim.keymap.set({ "n", "v" }, "q", "<Cmd>quit!<CR>", { buffer = true })
            vim.keymap.set("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, buffer = true })
            vim.keymap.set("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true, buffer = true })
            vim.keymap.set("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true, buffer = true })
            vim.keymap.set(
                "n",
                "<Down>",
                'v:count || mode(1)[0:1] == "no" ? "j" : "gj"',
                { expr = true, buffer = true }
            )
        end, 10)
    end,
})
