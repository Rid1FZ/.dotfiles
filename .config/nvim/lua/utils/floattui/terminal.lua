---@class FloatTUITerminal
local M = {}

local floattui = require("utils.floattui")

local api = vim.api
local keymap = vim.keymap

---Generate keymap options for a specific buffer
---@param buf integer Buffer number
---@return vim.keymap.set.Opts Options table for keymap
local function opts(buf)
    return {
        buffer = buf,
        noremap = true,
        silent = true,
        nowait = true,
    }
end

---Set keymappings for the terminal buffer
---@param buf integer Buffer number
---@param win integer Window number
---@return nil
local set_keymappings = function(buf, win)
    keymap.set("t", "<Esc><Esc>", function()
        api.nvim_win_close(win, true)
    end, opts(buf))
end

---Open a floating terminal window
---Uses the shell from environment variable SHELL, or falls back to /bin/sh
---@return {buf: integer, win: integer} Terminal instance with buffer and window numbers
M.open = function()
    local terminal = floattui.open(os.getenv("SHELL") or "/bin/sh")
    set_keymappings(terminal.buf, terminal.win)

    return terminal
end

return M
