---@class StatuslineFile
local M = {}

---@type table<integer, string>
local project_root_cache = {}

---@type table<integer, {filepath: string?, results: table<integer, string>}>
local file_path_cache = {}

---@type table<integer, string>
local file_icon_cache = {}

---@type table<integer, uv.uv_timer_t>
local debounce_timers = {}

local DEBOUNCE_MS = 150

local api = vim.api
local fn = vim.fn
local bo = vim.bo -- always use the index form: bo[something]
local uv = vim.uv
local fs = vim.fs
local defer_fn = vim.defer_fn
local cmd = vim.cmd

local colors = require("utils.statusline.highlights.colors")
local highlight = require("utils").highlight

---@type string[]
local root_markers = {
    ".git",
    ".hg",
    ".svn",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "pyproject.toml",
    "Makefile",
}

---Debounced cache invalidation for a given buffer.
---Coalesces rapid back-to-back buffer events (e.g. BufWritePost fired multiple
---times in quick succession) into a single cache clear + statusline redraw so
---that the component never recomputes more often than necessary.
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
        project_root_cache[bufnr] = nil
        file_path_cache[bufnr] = nil
        file_icon_cache[bufnr] = nil
        debounce_timers[bufnr] = nil
        -- Only redraw if the buffer still exists
        if api.nvim_buf_is_valid(bufnr) then
            cmd.redrawstatus()
        end
    end, DEBOUNCE_MS)
end

---Find the project root directory for the current buffer.
---Uses common project markers like .git, package.json, etc.
---Result is cached per-buffer and invalidated via debounced_invalidate.
---@return string Project root path
local function get_project_root()
    local bufnr = api.nvim_get_current_buf()
    if project_root_cache[bufnr] then
        return project_root_cache[bufnr]
    end

    local file = api.nvim_buf_get_name(bufnr)
    if file == "" then
        local cwd = uv.cwd()
        project_root_cache[bufnr] = cwd
        return cwd
    end

    local found = fs.find(root_markers, { upward = true, path = file })[1]
    local root = found and fs.dirname(found) or uv.cwd()

    project_root_cache[bufnr] = root
    return root
end

---Get file icon component with appropriate highlighting.
---Uses nvim-web-devicons for filetype-specific icons.
---@return string Statusline format string with file icon (empty for special buffers)
M.get_fileicon = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    -- Return cached result if present (cache is invalidated via debounced_invalidate)
    if file_icon_cache[bufnr] ~= nil then
        return file_icon_cache[bufnr]
    end

    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then
        file_icon_cache[bufnr] = ""
        return file_icon_cache[bufnr]
    end

    local fname = fn.expand("%:t")
    if fname == "" then
        -- Do not cache a missing filename – the buffer may still be loading.
        return ""
    end

    local extension = fn.expand("%:e")
    local icon, icon_color = devicons.get_icon_color(fname, extension, { default = true })

    if icon then
        highlight("StatusLineFileIcon", { bg = colors.bg, fg = icon_color })
        file_icon_cache[bufnr] = "%#StatusLineFileIcon#" .. icon .. " %#StatusLine#"
    else
        file_icon_cache[bufnr] = ""
    end

    return file_icon_cache[bufnr]
end

---Get file path component relative to project root.
---@return string Statusline format string with file path (empty for special buffers)
M.get_filepath = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local win_width = api.nvim_win_get_width(0)

    -- Initialise the per-buffer cache table only once; never reset it inside
    -- this hot path (that was the original bug that caused perpetual misses).
    if not file_path_cache[bufnr] then
        file_path_cache[bufnr] = {
            filepath = nil,
            results = {},
        }
    end

    local result_cache = file_path_cache[bufnr].results

    -- A cached result for this exact window width already exists.
    -- Note: we store a sentinel string "~empty~" so we can distinguish
    -- "computed and empty" from "not yet computed" (nil).
    local cached = result_cache[win_width]
    if cached ~= nil then
        return cached == "~empty~" and "" or cached
    end

    local full_path = api.nvim_buf_get_name(bufnr)
    if full_path == "" then
        -- Buffer has no name yet (e.g. still loading); do not cache.
        return ""
    end

    -- Build the display path (root_name/relative/path) once per buffer.
    local display_path = file_path_cache[bufnr].filepath
    if not display_path then
        local root = get_project_root()
        local root_name = fn.fnamemodify(root, ":t")
        local relative_path = full_path:gsub("^" .. vim.pesc(root) .. "/", "")

        if relative_path == full_path then
            -- Path is outside the project root; show full absolute path.
            display_path = full_path
        elseif relative_path == "" then
            display_path = root_name
        else
            display_path = root_name .. "/" .. relative_path
        end

        file_path_cache[bufnr].filepath = display_path
    end

    -- Maximum path width is 30 % of the window.
    local max_path_width = math.floor(win_width * 0.3)
    local filename = fn.fnamemodify(full_path, ":t")

    local result
    if #display_path <= max_path_width then
        -- Full path fits.
        result = display_path
    elseif #filename <= max_path_width then
        -- Full path doesn't fit, but the bare filename does – show it with a
        -- leading ellipsis so the user still sees something meaningful.
        local tail_len = max_path_width - 1 -- 1 char for the "…"
        local tail = display_path:sub(#display_path - tail_len + 1)
        result = "…" .. tail
    else
        -- Even the filename exceeds the allotted width.  Truncate the filename
        -- itself rather than returning empty string (the original bug).
        result = filename:sub(1, max_path_width - 1) .. "…"
    end

    -- Store result; use sentinel for empty so we can distinguish from nil.
    result_cache[win_width] = result ~= "" and result or "~empty~"

    return result
end

---Get file modification status indicators.
---Shows [+] for modified, [-] for readonly/unmodifiable.
---@return string Statusline format string with status indicators (spaces if unchanged)
M.get_modified_status = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local s = ""
    if bo[bufnr].modified then
        s = s .. "[+] "
    end
    if bo[bufnr].readonly or not bo[bufnr].modifiable then
        s = s .. "[-] "
    end
    return #s > 0 and s or "   "
end

-- Debounced cache invalidation on buffer lifecycle events.
-- Using defer_fn coalesces bursts of events (e.g. multiple BufWritePost from a
-- formatter) into a single recompute, matching the debounce pattern used in
-- other statusline components such as the git branch component.
api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufDelete" }, {
    group = api.nvim_create_augroup("StatuslineFileDebounce", { clear = true }),
    callback = function(args)
        debounced_invalidate(args.buf)
    end,
})

return M
