local opt = vim.opt_local

if vim.bo.buftype == "nofile" then
  opt.number = true
  opt.relativenumber = false
  opt.cursorline = false
  opt.signcolumn = "no"
end
