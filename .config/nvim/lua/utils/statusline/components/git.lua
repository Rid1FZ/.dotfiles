local M = {}

local fn = vim.fn
local api = vim.api

local last_branch = ""
local last_cwd = ""

local function get_branch()
    if vim.bo.buftype ~= "" then
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

M.get_gitbranch = function()
    local branch = get_branch()
    local win_width = api.nvim_win_get_width(0)

    if branch == "" then
        return " "
    elseif (#branch + 2) > math.floor(win_width * 0.15) then
        return string.format("%%#StatusLineGitBranch#%%#StatusLine#  ")
    end

    return string.format("%%#StatusLineGitBranch# %s%%#StatusLine#  ", branch)
end

return M
