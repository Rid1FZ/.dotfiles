local M = {}
local tuis = {}

local get_win_config = function()
    local width = math.floor(vim.o.columns * 0.9)
    local height = math.floor(vim.o.lines * 0.8)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - (vim.o.cmdheight + 2 + height)) / 2)

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

local create_floating_window = function(opts)
    opts = opts or {}

    -- Create a buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
    end

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, get_win_config())

    return { buf = buf, win = win }
end

local set_autocommands = function(buf, win)
    -- Close floating window if process exits
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        group = vim.api.nvim_create_augroup("CloseTerminalBuffer", { clear = true }),
        callback = function()
            vim.api.nvim_win_close(win, true)
            vim.cmd.bwipeout({ buf, bang = true })
        end,
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("ResizeTerminalBuffer", {}),
        callback = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_set_config(win, get_win_config())
                vim.api.nvim_win_set_cursor(win, { 1, 0 })
            end
        end,
    })
end

M.open = function(command)
    if tuis[command] == nil then
        tuis[command] = {
            buf = -1,
            win = -1,
        }
    end

    if not vim.api.nvim_win_is_valid(tuis[command].win) then
        tuis[command] = create_floating_window({ buf = tuis[command].buf })
        if vim.bo[tuis[command].buf].buftype ~= "terminal" then
            vim.cmd.terminal(command)
        end
        set_autocommands(tuis[command].buf, tuis[command].win)
        vim.cmd([[startinsert]])
    end

    return tuis[command]
end

return M
