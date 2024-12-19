local M = {}
local null_ls = require("null-ls")

M.sources = {
    -- formatting
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.shfmt,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.clang_format,
    null_ls.builtins.formatting.prettier,
    -- diagnostics
    null_ls.builtins.diagnostics.mypy,
}

M.on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format({
                    async = false,
                    timeout_ms = 5000,
                    bufnr = bufnr,
                    filter = function(client_)
                        return client_.name == "null-ls"
                    end,
                })
            end,
        })
    end
end

return M
