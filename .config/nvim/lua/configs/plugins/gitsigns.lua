local M = {}

M.on_attach = function(bufnr)
    require("utils").load_mappings("gitsigns", { buffer = bufnr })
end

M.signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "│" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
    untracked = { text = "│" },
}

return M
