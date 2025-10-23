local M = {}

local last_branch = ""
local last_cwd = ""

local function get_branch()
    if vim.bo.buftype ~= "" then
        return ""
    end

    local cwd = vim.fn.getcwd()

    if cwd == last_cwd and last_branch ~= "" then
        return last_branch
    end

    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
    if not branch or branch == "" or branch == "HEAD" then
        branch = ""
    end

    last_branch = branch
    last_cwd = cwd

    return branch
end

M.get_gitbranch = function()
    local branch = get_branch()

    if branch ~= "" then
        return string.format("%%#StatusLineGitBranch# %s%%#StatusLine#  ", branch)
    else
        return " "
    end
end

return M
