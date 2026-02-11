---@class StatuslineFile
local M = {}

---@type table<integer, string>
local project_root_cache = {}

---@type table<integer, {filepath: string?, results: table<integer, string>}>
local file_path_cache = {}

---@type table<integer, string>
local file_icon_cache = {}

local api = vim.api
local fn = vim.fn
local bo = vim.bo -- always use the index form: bo[something]
local uv = vim.uv
local fs = vim.fs

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

---Find the project root directory for the current buffer
---Uses common project markers like .git, package.json, etc.
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

---Get file icon component with appropriate highlighting
---Uses nvim-web-devicons for filetype-specific icons
---@return string Statusline format string with file icon (empty for special buffers)
M.get_fileicon = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    if file_icon_cache[bufnr] then
        return file_icon_cache[bufnr]
    end

    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then
        file_icon_cache[bufnr] = ""
        return file_icon_cache[bufnr]
    end

    local fname = fn.expand("%:t")
    if fname == "" then
        file_icon_cache[bufnr] = ""
        return file_icon_cache[bufnr]
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

---Get file path component relative to project root
---@return string Statusline format string with file path (empty for special buffers)
M.get_filepath = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local win_width = api.nvim_win_get_width(0)

    -- Setup the cache
    file_path_cache[bufnr] = {
        filepath = nil,
        results = {},
    }

    local result_cache = file_path_cache[bufnr].results or {}

    if result_cache[win_width] then
        return result_cache[win_width]
    end

    local display_path
    if file_path_cache[bufnr].filepath then
        display_path = file_path_cache[bufnr].filepath
    else
        local full_path = api.nvim_buf_get_name(bufnr)
        if full_path == "" then
            return ""
        end

        local root = get_project_root()
        local root_name = fn.fnamemodify(root, ":t")
        local relative_path = full_path:gsub("^" .. vim.pesc(root) .. "/", "")

        if relative_path == "" then
            display_path = root_name
        else
            display_path = root_name .. "/" .. relative_path
        end

        file_path_cache[bufnr].filepath = display_path
    end

    -- Calculate max path width (30% of window)
    local max_path_width = math.floor(win_width * 0.3)

    -- Get filename for fallback
    local filename = fn.fnamemodify(api.nvim_buf_get_name(bufnr), ":t")
    local result
    if max_path_width < #filename then
        result = ""
    elseif #display_path > max_path_width then
        local truncate_length = max_path_width - 3 -- Reserve 3 chars for "..."
        result = "..." .. display_path:sub(#display_path - truncate_length + 1)
    else
        result = display_path
    end

    result_cache[win_width] = result

    return result
end

---Get file modification status indicators
---Shows [+] for modified, [-] for readonly/unmodifiable
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

-- Clear cache on buffer events
api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufDelete" }, {
    callback = function(args)
        project_root_cache[args.buf] = nil
        file_path_cache[args.buf] = nil
        file_icon_cache[args.buf] = nil
    end,
})

return M
