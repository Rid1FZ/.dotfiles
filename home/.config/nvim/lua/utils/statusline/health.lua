local M = {}

M.check = function()
    local h = vim.health
    local fn = vim.fn

    --------------------------------------------------------------------
    -- Section 1: file icon component depends on nvim-web-devicons
    --------------------------------------------------------------------
    h.start("File icons")

    local ok_devicons, devicons = pcall(require, "nvim-web-devicons")
    if ok_devicons then
        local ok_icon = pcall(function() devicons.get_icon("init.lua", "lua", { default = true }) end)
        if ok_icon then
            h.ok("`nvim-web-devicons` · available and functional")
        else
            h.warn(
                "`nvim-web-devicons` · loaded but `get_icon()` failed",
                { "Ensure `nvim-web-devicons` `setup()` has been called before running `:checkhealth`" }
            )
        end
    else
        h.warn(
            "`nvim-web-devicons` · not found · file icon component will be empty",
            { "Install `nvim-web-devicons` (declared in `plugin/nvim-web-devicons.lua`)" }
        )
    end

    --------------------------------------------------------------------
    -- Section 2: git branch component depends on the git binary
    --------------------------------------------------------------------
    h.start("Git branch")

    local resolved = fn.exepath("git")
    if resolved ~= "" then
        local result = vim.system({ "git", "--version" }, { text = true }):wait(2000)
        if result.code == 0 then
            h.ok(("`git` · `%s` · %s"):format(resolved, vim.trim(result.stdout)))
        else
            h.ok(("`git` · `%s`"):format(resolved))
        end
    else
        h.warn(
            "`git` · not found · branch component will always be empty",
            { "Install `git` and ensure it is on `PATH`" }
        )
    end
end

return M
