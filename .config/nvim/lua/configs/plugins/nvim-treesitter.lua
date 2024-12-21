local M = {}

M.auto_install = true
M.sync_install = true

M.indent = { enable = true }

M.highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = false,
}

M.ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "markdown_inline",
    "comment",
}

return M
