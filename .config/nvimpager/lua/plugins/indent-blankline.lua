return {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",

    opts = require("configs.plugins.indent-blankline"),
    config = function(_, opts)
        require("ibl").setup(opts)
    end,
}
