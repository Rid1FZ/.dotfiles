local M = {}
local null_ls = require("null-ls")

M.sources = {
    -- python
    null_ls.builtins.formatting.black.with({
        extra_args = { "--line-length", "120" },
    }),
    null_ls.builtins.formatting.isort,
    null_ls.builtins.diagnostics.mypy,

    -- lua
    null_ls.builtins.formatting.stylua,

    -- bash
    null_ls.builtins.formatting.shfmt.with({
        filetypes = { "bash", "zsh", "sh" },
        extra_args = { "--indent", "4", "--case-indent", "--language-dialect", "bash" },
    }),

    -- c/c++
    null_ls.builtins.formatting.clang_format,

    -- json/markdown
    null_ls.builtins.formatting.prettier,

    -- rust
    require("none-ls.formatting.rustfmt"),
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
