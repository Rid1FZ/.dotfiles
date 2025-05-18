local M = {}
local null_ls = require("null-ls")

M.sources = {
    -- python
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.isort,

    -- lua
    null_ls.builtins.formatting.stylua,

    -- bash
    null_ls.builtins.formatting.shfmt.with({
        filetypes = { "bash", "zsh", "sh" },
        extra_args = { "--indent", "4", "--case-indent", "--language-dialect", "bash" },
    }),

    -- c/c++
    null_ls.builtins.formatting.clang_format.with({
        extra_args = {
            [[--style={ BasedOnStyle: Google, AlignAfterOpenBracket: Align, AllowShortBlocksOnASingleLine: 'false', AllowShortCaseLabelsOnASingleLine: 'false', AllowShortFunctionsOnASingleLine: InlineOnly, AllowShortIfStatementsOnASingleLine: Always, IndentWidth: '4', SortUsingDeclarations: 'true', SpaceAfterCStyleCast: 'false', SpacesInAngles: 'false', SpacesInParentheses: 'false', SpacesInSquareBrackets: 'true', TabWidth: '4', UseTab: Never }]],
        },
    }),

    -- json/markdown
    null_ls.builtins.formatting.prettier,

    -- rust
    require("none-ls.formatting.rustfmt"),

    -- assembly
    null_ls.builtins.formatting.asmfmt,
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
