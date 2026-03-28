return {
    "windwp/nvim-autopairs",
    event = "InsertEnter",

    init = function() require("utils").load_mappings("nvim-autopairs") end,

    opts = {
        map_cr = false,
        fast_wrap = {},
        disable_filetype = { "TelescopePrompt", "vim" },
    },
}
