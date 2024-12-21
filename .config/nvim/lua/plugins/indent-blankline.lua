return {
    "lukas-reineke/indent-blankline.nvim",
    event = "User FilePost",
    main = "ibl",

    opts = function()
        return require("configs.plugins.indent-blankline")
    end,

    config = function(_, opts)
        require("ibl").setup(opts)
    end,
}
