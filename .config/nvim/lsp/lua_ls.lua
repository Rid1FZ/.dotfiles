local function build_library()
    local library = {}

    library[vim.env.VIMRUNTIME] = true
    library["${3rd}/luv/library"] = true
    library["${3rd}/busted/library"] = true

    for _, plugin in ipairs(vim.pack.get()) do
        library[plugin.path] = true
    end

    return library
end

return {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", "stylua.toml", ".git" },
    filetypes = { "lua" },

    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            diagnostics = {
                globals = {
                    "vim",
                },
                disable = {
                    "missing-fields",
                },
            },
            workspace = {
                library = build_library(),

                checkThirdParty = false,
                maxPreload = 100000,
                preloadFileSize = 100000,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
