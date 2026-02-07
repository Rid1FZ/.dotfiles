---@class FloatTUI
local M = {}

---@class TUIInstance
---@field buf integer Buffer number
---@field win integer Window number

---@type table<string, TUIInstance>
local tuis = {}

local floor = math.floor
local o = vim.o
local bo = vim.bo -- always use the index form: bo[something]
local api = vim.api
local cmd = vim.cmd

---Get window configuration for floating window
---@return vim.api.keyset.win_config
local get_win_config = function()
    local columns = o.columns
    local lines = o.lines
    local cmdheight = o.cmdheight

    local width = floor(columns * 0.9)
    local height = floor(lines * 0.8)
    local col = floor((columns - width) / 2)
    local row = floor((lines - (cmdheight + 2 + height)) / 2)

    return {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal", -- No borders or extra UI elements
        border = "rounded",
    }
end

---Create a floating window
---@param opts? {buf?: integer}
---@return TUIInstance
local create_floating_window = function(opts)
    opts = opts or {}

    -- Create a buffer
    local buf = nil
    if api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = api.nvim_create_buf(false, true) -- No file, scratch buffer
    end

    -- Create the floating window
    local win = api.nvim_open_win(buf, true, get_win_config())

    return { buf = buf, win = win }
end

---Set autocommands for terminal buffer
---@param buf integer Buffer number
---@param win integer Window number
---@return nil
local set_autocommands = function(buf, win)
    -- Close floating window if process exits
    api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        group = api.nvim_create_augroup("CloseTerminalBuffer", { clear = true }),
        callback = function()
            api.nvim_win_close(win, true)
            cmd.bwipeout({ buf, bang = true })
        end,
    })

    api.nvim_create_autocmd("VimResized", {
        group = api.nvim_create_augroup("ResizeTerminalBuffer", {}),
        callback = function()
            if api.nvim_win_is_valid(win) then
                api.nvim_win_set_config(win, get_win_config())
                api.nvim_win_set_cursor(win, { 1, 0 })
            end
        end,
    })
end

---Open a TUI application in a floating window
---@param command string The command to run
---@return TUIInstance
M.open = function(command)
    if tuis[command] == nil then
        tuis[command] = {
            buf = -1,
            win = -1,
        }
    end

    if not api.nvim_win_is_valid(tuis[command].win) then
        tuis[command] = create_floating_window({ buf = tuis[command].buf })
        if bo[tuis[command].buf].buftype ~= "terminal" then
            cmd.terminal(command)
        end
        set_autocommands(tuis[command].buf, tuis[command].win)
        cmd.startinsert()
    end

    return tuis[command]
end

return M
