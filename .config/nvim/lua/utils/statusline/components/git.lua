---@class StatuslineGit
local M = {}

local fn = vim.fn
local api = vim.api
local bo = vim.bo -- always use the index form: bo[something]
local format = string.format
local floor = math.floor

---@type string
local last_branch = ""

---@type string
local last_cwd = ""

---Get the current git branch name
---@return string Git branch name (empty if not in a git repository)
local function get_branch()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local cwd = fn.getcwd()

    if cwd == last_cwd and last_branch ~= "" then
        return last_branch
    end

    local branch = fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    if not branch or branch == "" or branch == "HEAD" then
        branch = ""
    end

    last_branch = branch
    last_cwd = cwd

    return branch
end

---Get git branch component for statusline
---@return string Statusline format string with git branch (space if not in repo)
M.get_gitbranch = function()
    local branch = get_branch()
    local win_width = api.nvim_win_get_width(0)

    if branch == "" then
        return " "
    elseif (#branch + 2) > floor(win_width * 0.15) then
        return format("%%#StatusLineGitBranch#%%#StatusLine#  ")
    end

    return format("%%#StatusLineGitBranch# %s%%#StatusLine#  ", branch)
end

return M
