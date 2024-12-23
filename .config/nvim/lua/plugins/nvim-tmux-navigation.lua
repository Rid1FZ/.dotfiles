return {
    "alexghergh/nvim-tmux-navigation",
    event = "VimEnter",

    config = function()
        require("nvim-tmux-navigation").setup({})
    end,
}
