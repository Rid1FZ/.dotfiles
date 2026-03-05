---@class StatuslineDiagnostics
local M = {}

local api = vim.api
local bo = vim.bo -- always use the index form: bo[something]
local diagnostic = vim.diagnostic
local tbl_count = vim.tbl_count
local defer_fn = vim.defer_fn
local cmd = vim.cmd
local format = string.format
local concat = table.concat

---@type table<string, vim.diagnostic.Severity>
local severity = {
    errors = diagnostic.severity.ERROR,
    warnings = diagnostic.severity.WARN,
    info = diagnostic.severity.INFO,
    hints = diagnostic.severity.HINT,
}

---@type table<string, string>
local symbols = {
    errors = "",
    warnings = "",
    info = "",
    hints = "",
}

---@type table<string, string>
local highlights = {
    errors = "DiagnosticSignError",
    warnings = "DiagnosticSignWarn",
    info = "DiagnosticSignInfo",
    hints = "DiagnosticSignHint",
}

-- Per-buffer cache: nil means "not yet computed", any string (including "") means
-- the last computed result.  The sentinel approach used in file.lua is not needed
-- here because an empty string is a perfectly valid cached result (= no diagnostics).
---@type table<integer, string>
local cache = {}

local DEBOUNCE_MS = 150

-- One libuv timer per buffer, used to debounce DiagnosticChanged events.
-- Storing the timer handle lets us cancel a pending invalidation if the event
-- fires again before the delay has elapsed (trailing-edge debounce).
---@type table<integer, uv.uv_timer_t>
local debounce_timers = {}

---Compute and cache the diagnostic statusline string for `bufnr`.
---Separated from get_diagnostics so it can be called both from the render path
---and from the debounce callback.
---@param bufnr integer
---@return string
local function compute(bufnr)
    local result = {}
    local total = 0

    for key, sev in pairs(severity) do
        local n = tbl_count(diagnostic.get(bufnr, { severity = sev }))
        if n > 0 then
            total = total + n
            result[#result + 1] = format("%%#%s#%s %d", highlights[key], symbols[key], n)
        end
    end

    local s = ""
    if total > 0 then
        result[#result + 1] = "%#StatusLine#"
        s = concat(result, " ")
    end

    cache[bufnr] = s
    return s
end

---Debounced cache invalidation.
---Cancels any pending timer for `bufnr` and schedules a fresh recompute after
---DEBOUNCE_MS milliseconds.  If DiagnosticChanged fires again within the window,
---the old timer is replaced, giving trailing-edge debounce semantics identical
---to file.lua and git.lua.
---@param bufnr integer
---@return nil
local function debounced_invalidate(bufnr)
    local timer = debounce_timers[bufnr]
    if timer then
        timer:stop()
        timer:close()
        debounce_timers[bufnr] = nil
    end

    debounce_timers[bufnr] = defer_fn(function()
        debounce_timers[bufnr] = nil
        if not api.nvim_buf_is_valid(bufnr) then
            cache[bufnr] = nil
            return
        end
        compute(bufnr)
        cmd.redrawstatus()
    end, DEBOUNCE_MS)
end

-- Invalidate the cache whenever diagnostics change for a buffer.
-- DiagnosticChanged carries the buffer number in args.buf, so we can
-- invalidate only the affected buffer rather than flushing everything.
api.nvim_create_autocmd("DiagnosticChanged", {
    group = api.nvim_create_augroup("StatuslineDiagnosticsDebounce", { clear = true }),
    callback = function(args)
        debounced_invalidate(args.buf)
    end,
})

---Get diagnostics component for current buffer.
---Returns a cached string on every statusline render; the cache is refreshed
---asynchronously via the DiagnosticChanged autocmd above.
---@return string Statusline format string with diagnostic information (empty if none)
M.get_diagnostics = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    -- Return cached value if present; compute synchronously on first render.
    if cache[bufnr] ~= nil then
        return cache[bufnr]
    end

    return compute(bufnr)
end

return M
