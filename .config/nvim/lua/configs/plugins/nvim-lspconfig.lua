local lspconfig = require("lspconfig")
local lsp = require("configs.lsp")

lspconfig.pyright.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
            },
        },
    },
})

lspconfig.clangd.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
})

lspconfig.bashls.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
})

lspconfig.lua_ls.setup({
    on_init = lsp.on_init,
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,

    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                    [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})
