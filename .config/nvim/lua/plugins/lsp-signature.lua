return {
    "ray-x/lsp_signature.nvim",
    event = "LspAttach",

    opts = function()
        return require("configs.plugins.lsp-signature")
    end,
}
