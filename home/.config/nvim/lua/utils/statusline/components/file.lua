---@class StatuslineFile
local M = {}

local utils = require("utils")

local api = vim.api
local fn = vim.fn
local opt = vim.o
local bo = vim.bo -- always use the index form: bo[something]
local uv = vim.uv
local fs = vim.fs
local cmd = vim.cmd

local colors = require("utils.statusline.highlights.colors")
local highlight = require("utils").highlight

---@type table<integer, string>
local project_root_cache = {}

---@type table<integer, {filepath: string?, results: table<integer, string>}>
local file_path_cache = {}

---@type table<integer, string>
local file_icon_cache = {}

local DEBOUNCE_MS = 150

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
---@type fun(bufnr: integer): nil
local debounced_invalidate = utils.debounce_by_key(function(bufnr)
    project_root_cache[bufnr] = nil
    file_path_cache[bufnr] = nil
    file_icon_cache[bufnr] = nil

    if api.nvim_buf_is_valid(bufnr) then
        cmd.redrawstatus()
    end
end, DEBOUNCE_MS)

---Find the project root directory for the current buffer.
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
        return cwd --[[@as string]]
    end

    local found = fs.find(root_markers, { upward = true, path = file })[1]
    local root = found and fs.dirname(found) or uv.cwd()

    project_root_cache[bufnr] = root
    return root
end

---Get file icon component with appropriate highlighting.
---@return string Statusline format string with file icon (empty for special buffers)
M.get_fileicon = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

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

    -- vim.fs.ext() is the 0.12 pure-Lua replacement for fn.expand("%:e").
    local extension = vim.fs.ext(fname) or ""
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

    local win_width = opt.columns

    if not file_path_cache[bufnr] then
        file_path_cache[bufnr] = {
            filepath = nil,
            results = {},
        }
    end

    local result_cache = file_path_cache[bufnr].results

    local cached = result_cache[win_width]
    if cached ~= nil then
        return cached == "~empty~" and "" or cached
    end

    local full_path = api.nvim_buf_get_name(bufnr)
    if full_path == "" then
        return ""
    end

    local display_path = file_path_cache[bufnr].filepath
    if not display_path then
        local root = get_project_root()
        local root_name = fn.fnamemodify(root, ":t")
        local relative_path = full_path:gsub("^" .. vim.pesc(root) .. "/", "")

        if relative_path == full_path then
            display_path = full_path
        elseif relative_path == "" then
            display_path = root_name
        else
            display_path = root_name .. "/" .. relative_path
        end

        file_path_cache[bufnr].filepath = display_path
    end

    local max_path_width = math.floor(win_width * 0.3)
    local filename = fn.fnamemodify(full_path, ":t")

    local result
    if #display_path <= max_path_width then
        result = display_path
    elseif #filename <= max_path_width then
        local tail_len = max_path_width - 1
        local tail = display_path:sub(#display_path - tail_len + 1)
        result = "…" .. tail
    else
        result = filename:sub(1, max_path_width - 1) .. "…"
    end

    result_cache[win_width] = result ~= "" and result or "~empty~"

    return result
end

---Get file modification status indicators.
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

api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufDelete", "BufFilePost" }, {
    group = api.nvim_create_augroup("StatuslineFileDebounce", { clear = true }),
    callback = function(args) debounced_invalidate(args.buf) end,
})

return M
