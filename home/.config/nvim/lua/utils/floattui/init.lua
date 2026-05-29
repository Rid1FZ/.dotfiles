---@class FloatTUI
local M = {}

---@class TUIInstance
---@field buf integer Buffer number
---@field win integer Window number

---@type table<string, TUIInstance>
local tuis = {}

---Tracks every floating window opened by this module so the single, module-level
---VimResized handler can resize all of them without accumulating duplicate autocmds.
---@type table<integer, true>
local float_wins = {}

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

-- Single module-level VimResized handler
api.nvim_create_autocmd("VimResized", {
    group = api.nvim_create_augroup("FloatTUIResize", { clear = true }),
    callback = function()
        for win in pairs(float_wins) do
            if api.nvim_win_is_valid(win) then
                api.nvim_win_set_config(win, get_win_config())
            else
                -- Prune stale entries so the table stays small.
                float_wins[win] = nil
            end
        end
    end,
})

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

    -- Register the new window so the module-level resize handler can find it.
    float_wins[win] = true

    return { buf = buf, win = win }
end

---Set autocommands for terminal buffer.
---
---Only a TermClose handler is registered here.  The VimResized handler is
---intentionally kept at module level (see above) so it is registered exactly
---once regardless of how many terminals are opened.
---
---Each TermClose handler gets its own uniquely-named augroup so that
---re-opening the same buffer always replaces the old handler rather than
---stacking a second one on top.
---@param buf integer Buffer number
---@param win integer Window number
---@return nil
local set_autocommands = function(buf, win)
    -- Use a buffer-specific group name so re-opening the same buffer clears
    -- any handler registered during a previous open.
    local close_group = api.nvim_create_augroup("FloatTUIClose_" .. buf, { clear = true })

    api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        group = close_group,
        callback = function()
            -- Remove from tracking table before attempting to close the window
            -- so the VimResized handler never tries to resize a dying window.
            float_wins[win] = nil

            if api.nvim_win_is_valid(win) then
                api.nvim_win_close(win, true)
            end

            pcall(vim.api.nvim_buf_delete, buf, { force = true })
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
