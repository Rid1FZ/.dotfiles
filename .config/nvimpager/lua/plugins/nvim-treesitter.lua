return {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",

    opts = {
        auto_install = true,
        sync_install = true,

        indent = { enable = true },

        highlight = {
            enable = true,
            use_languagetree = true,
            additional_vim_regex_highlighting = false,
        },

        ensure_installed = {
            "markdown",
            "json",
            "jsonc",
            "json5",
            "vimdoc",
            "markdown_inline",
            "comment",
        },
    },

    config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
    end,
}
