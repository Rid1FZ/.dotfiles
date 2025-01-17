local M = {}

M.icons = require("configs.lspkind-icons")
M.color_icons = true
M.separator = ""

M.disabled_filetype = {
    "",
    "help",
    "NvimTree",
    "lazy",
    "mason",
}

return M
