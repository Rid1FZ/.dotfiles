local M = {}

local project_root_cache = {}
local file_path_cache = {}
local file_icon_cache = {}
local last_icon_color

local api = vim.api
local fn = vim.fn
local bo = vim.bo
local uv = vim.uv
local fs = vim.fs

local colors = require("utils.statusline.highlights.colors")
local highlight = require("utils").highlight

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

M.get_fileicon = function()
    if bo.buftype ~= "" then
        return ""
    end

    local bufnr = api.nvim_get_current_buf()
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

M.get_filepath = function()
    if bo.buftype ~= "" then
        return ""
    end

    local bufnr = api.nvim_get_current_buf()
    if file_path_cache[bufnr] then
        return file_path_cache[bufnr]
    end

    local full_path = api.nvim_buf_get_name(bufnr)
    if full_path == "" then
        return ""
    end

    local root = get_project_root()
    local root_name = fn.fnamemodify(root, ":t")
    local relative_path = full_path:gsub("^" .. vim.pesc(root) .. "/", "")

    local display_path
    if relative_path == "" then
        display_path = root_name
    else
        display_path = root_name .. "/" .. relative_path
    end

    local len = #display_path
    if len > 64 then
        display_path = "..." .. display_path:sub(len - 61)
    end

    file_path_cache[bufnr] = display_path
    return display_path
end

M.get_modified_status = function()
    if bo.buftype ~= "" then
        return ""
    end

    local s = ""
    if bo.modified then
        s = s .. "[+] "
    end
    if bo.readonly or not bo.modifiable then
        s = s .. "[-] "
    end
    return #s > 0 and s or "   "
end

api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "BufDelete" }, {
    callback = function(args)
        project_root_cache[args.buf] = nil
        file_path_cache[args.buf] = nil
        file_icon_cache[args.buf] = nil
    end,
})

return M
