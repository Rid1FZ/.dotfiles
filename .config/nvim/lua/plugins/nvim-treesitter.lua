return {
    "nvim-treesitter/nvim-treesitter",
    event = "User FilePost",
    branch = "main",
    build = ":TSUpdate",
}
