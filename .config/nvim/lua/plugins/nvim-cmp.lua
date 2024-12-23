return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    keys = { ":" },

    dependencies = {
        "nvim-telescope/telescope.nvim",
        "L3MON4D3/LuaSnip",
        "windwp/nvim-autopairs",

        -- cmp sources plugins
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
    },

    config = function()
        local cmp = require("cmp")
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")

        cmp.setup(require("configs.plugins.nvim-cmp"))
        cmp.setup.cmdline(":", require("configs.plugins.nvim-cmp-cmdline"))

        -- setup cmp for autopairs
        require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
}
