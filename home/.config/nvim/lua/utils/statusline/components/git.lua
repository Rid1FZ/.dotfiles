---@class StatuslineGit
local M = {}

local utils = require("utils")

local opt = vim.o
local system = vim.system
local cmd = vim.cmd
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

local DEBOUNCE_MS = 100

---Debounced branch refresh.
---Cancels any in-flight git job and pending timer, then schedules a fresh
---`git branch --show-current` call after DEBOUNCE_MS milliseconds.
---@type fun(cwd: string): nil
local debounced_invalidate = utils.debounce_by_key(function(cwd)
    -- Guard with is_closing() before kill() — calling kill() on a handle
    -- that is already closing or closed could race.
    if git_job and not git_job:is_closing() then
        git_job:kill(9)
    end
    git_job = nil

    git_job = system(
        { "git", "branch", "--show-current" },
        -- Pass cwd explicitly rather than relying on Neovim's inherited cwd,
        -- which could shift between when the debounce was armed and when it fires.
        { text = true, cwd = cwd },
        schedule_wrap(function(obj)
            git_job = nil

            -- Always update last_cwd regardless of outcome.
            last_cwd = cwd

            if obj.code == 0 then
                local branch = obj.stdout:gsub("\n", "")
                last_branch = (branch ~= "" and branch ~= "HEAD") and branch or ""
            else
                last_branch = ""
            end

            cmd.redrawstatus()
        end)
    )
end, DEBOUNCE_MS)

---Get the current git branch name
---@return string Git branch name (empty if not in a git repository)
local function get_branch()
    local bufnr = api.nvim_get_current_buf()
    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local cwd = fn.getcwd()

    -- last_cwd is now always updated by the callback (success or failure), so
    -- a simple equality check is sufficient. No branch-not-empty guard needed.
    if cwd == last_cwd then
        return last_branch
    end

    debounced_invalidate(cwd)

    return last_branch
end

---Get git branch component for statusline
---@return string Statusline format string with git branch (space if not in repo)
M.get_gitbranch = function()
    local branch = get_branch()
    local win_width = opt.columns

    if branch == "" then
        return " "
    elseif (#branch + 2) > floor(win_width * 0.15) then
        return format("%%#StatusLineGitBranch#%%#StatusLine#  ")
    end

    return format("%%#StatusLineGitBranch# %s%%#StatusLine#  ", branch)
end

return M
