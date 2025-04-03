local lspconfig = require("lspconfig")
local lsp = require("configs.lsp")
local win = require("lspconfig.ui.windows")
local default_opts_ = win.default_opts

lsp.configure_diagnostics()

-- Borders for LspInfo window
win.default_opts = function(options)
    local opts = default_opts_(options)
    opts.border = "rounded"
    return opts
end

lspconfig.pyright.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
    settings = {
        ["python"] = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = "workspace",
            },
        },
    },
})

lspconfig.clangd.setup({
    -- capabilities = lsp.capabilities,
    capabilities = (function()
        local capabilities = vim.deepcopy(lsp.capabilities, true)
        capabilities.offsetEncoding = { "utf-16" }
        return capabilities
    end)(),
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
})

lspconfig.bashls.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
})

lspconfig.rust_analyzer.setup({
    capabilities = lsp.capabilities,
    on_attach = lsp.on_attach,
    on_init = lsp.on_init,
    settings = {
        ["rust_analyzer"] = {
            cargo = {
                allFeatures = true,
            },
        },
    },
})

lspconfig.taplo.setup({
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

lspconfig.asm_lsp.setup({
    on_init = lsp.on_init,
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
})
