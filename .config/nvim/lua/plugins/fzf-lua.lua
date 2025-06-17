return {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",

    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },

    init = function()
        require("utils").load_mappings("fzf-lua")
    end,

    opts = function()
        return require("configs.plugins.fzf-lua")
    end,
}
