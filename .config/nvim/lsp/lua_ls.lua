local lsp = require("configs.lsp")

local function get_plugins()
    local plugins = {}

    if not package.loaded.lazy then
        return plugins
    end

    local ok, lazy_config = pcall(require, "lazy.core.config")
    if not ok then
        return plugins
    end

    for _, plugin in pairs(lazy_config.plugins) do
        if plugin.dir then
            table.insert(plugins, plugin.dir)
        end
    end

    return plugins
end

local function build_library()
    local library = {}

    library[vim.env.VIMRUNTIME] = true
    library["${3rd}/luv/library"] = true
    library["${3rd}/busted/library"] = true
    library[vim.fn.stdpath("config")] = true

    local plugins = get_plugins()
    for _, plugin_path in ipairs(plugins) do
        library[plugin_path] = true
    end

    return library
end

return {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", "stylua.toml", ".git" },
    filetypes = { "lua" },
    on_init = lsp.on_init,
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,

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
