local opt_local = vim.opt_local
local bo = vim.bo -- always use the index form: bo[something]

if bo["buftype"] == "nofile" then
    opt_local.number = true
    opt_local.relativenumber = false
    opt_local.cursorline = false
    opt_local.signcolumn = "no"
end
