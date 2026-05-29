local M = {}

M.timeout = vim.o.timeoutlen
M.default_mappings = false

M.mappings = {
    i = {
        j = {
            k = "<Esc>",
            j = "<Esc>",
        },
    },
}

return M
