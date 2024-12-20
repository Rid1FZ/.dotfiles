local M = {}

local state = {
    floating = {
        buf = -1,
        win = -1,
    },
}

local create_floating_window = function(opts)
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.9)
    local height = opts.height or math.floor(vim.o.lines * 0.8)

    -- Calculate the position to center the window
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - (vim.o.cmdheight + 2 + height)) / 2)

    -- Create a buffer
    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
    end

    -- Define window configuration
    local win_config = {
        relative = "editor",
        width = width,
        height = height,
        col = col,
        row = row,
        style = "minimal", -- No borders or extra UI elements
        border = "rounded",
    }

    -- Create the floating window
    local win = vim.api.nvim_open_win(buf, true, win_config)

    return { buf = buf, win = win }
end

local set_autocommands = function(bufnr)
    -- Close floating window if process exits
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = bufnr,
        group = vim.api.nvim_create_augroup("CloseTerminalBuffer", { clear = true }),
        callback = function()
            vim.cmd([[bdelete]])
        end,
    })
end

local set_keymaps = function(bufnr)
    -- Use <Esc> to hide floating window
    vim.keymap.set("t", "<Esc>", function()
        vim.api.nvim_win_hide(state.floating.win)
    end, {
        desc = "Hide Floating TUI",
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
    })
end

M.open = function(command)
    if not vim.api.nvim_win_is_valid(state.floating.win) then
        state.floating = create_floating_window({ buf = state.floating.buf })
        if vim.bo[state.floating.buf].buftype ~= "terminal" then
            vim.cmd.terminal(command)
            set_autocommands(state.floating.buf)
            set_keymaps(state.floating.buf)
        end
        vim.cmd([[startinsert]])
    end
end

return M
