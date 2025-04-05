return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",

    opts = {
        map_cr = true,
        fast_wrap = {},
        disable_filetype = { "TelescopePrompt", "vim" },
    },
}
