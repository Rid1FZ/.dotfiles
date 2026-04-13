local M = {}

M.view = {
    style = "sign",
    signs = { add = "│", change = "│", delete = "│" },
}
M.mappings = { goto_first = "", goto_prev = "", goto_next = "", goto_last = "" } -- mappings will be set in the mappings module

return M
