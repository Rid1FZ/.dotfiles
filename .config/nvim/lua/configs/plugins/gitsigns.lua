local M = {}

-- stylua: ignore
---@param bufnr integer Buffer number
M.on_attach = function(bufnr)
    require("utils").load_mappings("gitsigns.on-attach", { buffer = bufnr })
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
