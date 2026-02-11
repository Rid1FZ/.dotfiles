---@class StatuslineGit
local M = {}

local system = vim.system
local cmd = vim.cmd
local defer_fn = vim.defer_fn
local schedule = vim.schedule
local schedule_wrap = vim.schedule_wrap
local fn = vim.fn
local api = vim.api
local bo = vim.bo -- always use the index form: bo[something]
local format = string.format
local floor = math.floor

---@type string
local last_branch = ""

---@type string
local last_cwd = ""

---@type vim.SystemObj?
local git_job = nil

---@type uv.uv_timer_t
local git_debounce_timer = nil

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

    if git_job and not git_job:is_closing() then
        git_job:kill(9)
    end

    if git_debounce_timer then
        git_debounce_timer:stop()
    end

    git_debounce_timer = defer_fn(function()
        git_job = system(
            { "git", "branch", "--show-current" },
            { text = true },
            schedule_wrap(function(obj)
                if obj.code == 0 then
                    local branch = obj.stdout:gsub("\n", "")
                    if branch ~= "" and branch ~= "HEAD" then
                        last_branch = branch
                        last_cwd = cwd
                        cmd.redrawstatus()
                    else
                        last_branch = ""
                    end
                else
                    last_branch = ""
                end
                git_job = nil
            end)
        )
    end, 100)

    return last_branch
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
