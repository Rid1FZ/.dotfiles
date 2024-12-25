local M = {}
local floattui = require("utils.floattui")

local function opts(buf)
    return {
        buffer = buf,
        noremap = true,
        silent = true,
        nowait = true,
    }
end

local set_keymappings = function(buf, win)
    vim.keymap.set("t", "<Esc><Esc>", function()
        vim.api.nvim_win_close(win, true)
    end, opts(buf))
end

M.open = function()
    local terminal = floattui.open(os.getenv("SHELL") or "/bin/sh")
    set_keymappings(terminal.buf, terminal.win)

    return terminal
end

return M
