local M = {}

M.check = function()
    local h = vim.health
    local fn = vim.fn

    --------------------------------------------------------------------
    -- Section 1: shell for the floating terminal
    --------------------------------------------------------------------
    h.start("Shell")

    local shell = os.getenv("SHELL")
    if shell then
        local resolved = fn.exepath(shell)
        if resolved ~= "" then
            h.ok(("`$SHELL` · `%s`"):format(resolved))
        else
            h.error(
                ("`$SHELL` is set but the binary was not found: `%s`"):format(shell),
                { "Fix your `$SHELL` environment variable or install the shell" }
            )
        end
    else
        h.warn(
            "`$SHELL` is not set · floating terminal will fall back to `/bin/sh`",
            { "Set `$SHELL` in your shell profile (e.g. `export SHELL=/bin/bash`)" }
        )
    end
end

return M
