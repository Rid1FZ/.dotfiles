return {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    main = "ibl",

    opts = {
        debounce = 100,
        whitespace = { highlight = { "Whitespace", "NonText" } },

        exclude = {
            filetypes = {
                "help",
                "terminal",
                "lazy",
                "",
            },
            buftypes = { "terminal" },
        },

        scope = {
            enabled = false,
            show_start = false,
            show_end = false,
        },
    },

    config = function(_, opts)
        require("ibl").setup(opts)
    end,
}
