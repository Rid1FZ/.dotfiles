local opt_local = vim.opt_local

if vim.bo.buftype == "nofile" then
    opt_local.number = true
    opt_local.relativenumber = false
    opt_local.cursorline = false
    opt_local.signcolumn = "no"
end
