local M = {}

local local_project = os.getenv("HOME") .. "/Projects/breadcrumb.nvim"
if (vim.uv or vim.loop).fs_stat(local_project) then
    M.dir = local_project
else
    M[1] = "Rid1FZ/breadcrumb.nvim"
end

M.opts = function()
    return require("configs.plugins.breadcrumb")
end

M.config = function(_, opts)
    require("breadcrumb").setup(opts)
end

return M
