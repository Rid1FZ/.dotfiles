local lsp = require("configs.lsp")

return {
    cmd = { "lua-language-server" },
    root_markers = { ".git" },
    filetypes = { "lua" },
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
}
