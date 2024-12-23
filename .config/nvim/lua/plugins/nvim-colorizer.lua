return {
    "NvChad/nvim-colorizer.lua",
    event = "User FilePost",

    opts = function()
        return require("configs.plugins.nvim-colorizer")
    end,

    config = function(_, opts)
        require("colorizer").setup(opts)
        vim.defer_fn(function()
            require("colorizer").attach_to_buffer(0)
        end, 0)
    end,
}
