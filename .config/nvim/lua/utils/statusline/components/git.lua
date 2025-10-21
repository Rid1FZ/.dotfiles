local M = {}

M.get_gitbranch = function()
    local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")

    function _G.gitbranch_text()
        return " " .. branch
    end

    if branch ~= "" then
        return "%#StatusLineGitBranch#%20{v:lua.gitbranch_text()}%#StatusLine#  "
    else
        return "%20( %)  " -- 20 chars empty space
    end
end

return M
