local M = {}
local project_root_cache = {}
local filepath_cache = {}

local colors = require("utils.statusline.highlights.colors")
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
    local bufnr = vim.api.nvim_get_current_buf()
    if project_root_cache[bufnr] then
        return project_root_cache[bufnr]
    end

    local current_file = vim.fn.expand("%:p")
    if current_file == "" then
        project_root_cache[bufnr] = vim.fn.getcwd()
        return project_root_cache[bufnr]
    end

    local current_dir = vim.fn.fnamemodify(current_file, ":h")
    while current_dir ~= "/" do
        for _, marker in ipairs(root_markers) do
            if
                vim.fn.isdirectory(current_dir .. "/" .. marker) == 1
                or vim.fn.filereadable(current_dir .. "/" .. marker) == 1
            then
                project_root_cache[bufnr] = current_dir
                return current_dir
            end
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
    end

    -- Fallback to current working directory
    project_root_cache[bufnr] = vim.fn.getcwd()
    return project_root_cache[bufnr]
end

M.get_fileicon = function()
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then
        return ""
    end

    local fname = vim.fn.expand("%:t")
    local extension = vim.fn.expand("%:e")

    if fname == "" then
        return ""
    end

    local icon, icon_color = devicons.get_icon_color(fname, extension, { default = true })

    if icon then
        vim.api.nvim_set_hl(0, "StatusLineFileIcon", { bg = colors.bg, fg = icon_color })
        return "%#StatusLineFileIcon#" .. icon .. " %#StatusLine#"
    end

    return ""
end

M.get_filepath = function()
    local bufnr = vim.api.nvim_get_current_buf()
    if filepath_cache[bufnr] then
        return filepath_cache[bufnr]
    end

    local full_path = vim.fn.expand("%:p")
    local root = get_project_root()
    local fname = vim.fn.expand("%:t")

    if fname == "" then
        return " "
    end

    local root_name = vim.fn.fnamemodify(root, ":t")
    local relative_path = full_path:gsub("^" .. vim.pesc(root) .. "/", "")

    local fdir = vim.fn.fnamemodify(relative_path, ":h")

    local fullpath = ""
    if fdir == "" or fdir == "." then
        fullpath = fname
    else
        fullpath = root_name .. "/" .. relative_path
    end

    -- If longer than 64, truncate from left with ...
    if #fullpath > 64 then
        fullpath = "..." .. string.sub(fullpath, -(64 - 3))
    end

    filepath_cache[bufnr] = string.format("%s ", fullpath)
    return filepath_cache[bufnr]
end

M.get_modified_status = function()
    local status = ""
    if vim.bo.modified then
        status = status .. "[+] "
    end
    if vim.bo.readonly or not vim.bo.modifiable then
        status = status .. "[-] "
    end
    if status ~= "" then
        return status
    end
    return "    "
end

return M
