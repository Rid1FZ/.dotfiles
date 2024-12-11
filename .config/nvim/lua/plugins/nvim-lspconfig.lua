return {
    "neovim/nvim-lspconfig",
    event = "User FilePost",

    config = function()
        require("configs.nvim-lspconfig")
    end,
}
