local M = {}

M.check = function()
    local h = vim.health
    local fn = vim.fn

    --------------------------------------------------------------------
    -- Section 1: Neovim version
    -- All utils rely on APIs introduced in 0.11/0.12. Check that the
    -- running version is new enough before anything else.
    --------------------------------------------------------------------
    h.start("Neovim version")

    local v = vim.version()
    local version_str = ("v%d.%d.%d"):format(v.major, v.minor, v.patch)

    if fn.has("nvim-0.12") == 1 then
        h.ok(("`neovim` · `%s`"):format(version_str))
    elseif fn.has("nvim-0.11") == 1 then
        h.warn(("`neovim` · `%s` · some 0.12 features will be unavailable"):format(version_str), {
            "Upgrade to Neovim ≥ 0.12 for full support",
        })
    else
        h.error(
            ("`neovim` · `%s` · minimum required version is 0.11"):format(version_str),
            { "Upgrade to Neovim ≥ 0.12" }
        )
    end

    --------------------------------------------------------------------
    -- Section 2: tree-sitter-manager
    -- Used by utils.start_treesitter to look up which parsers are
    -- configured. Without it, treesitter highlighting still starts when
    -- a parser is already installed, but the "available but not
    -- installed" notification is suppressed.
    --------------------------------------------------------------------
    h.start("Treesitter")

    local ok_tsm, _ = pcall(require, "tree-sitter-manager")
    if not ok_tsm then
        h.error(
            "`tree-sitter-manager` · plugin not found",
            { "Install `romus204/tree-sitter-manager.nvim` (declared in `plugin/tree-sitter-manager.lua`)" }
        )
        goto skip_tsm
    end

    do
        local ok_cfg, cfg = pcall(require, "tree-sitter-manager.config")
        if not ok_cfg then
            -- Plugin loaded but config not initialised yet (setup() not called).
            h.warn(
                "`tree-sitter-manager` · loaded but config is not initialised",
                { "Run `:checkhealth` after startup completes (setup is deferred 10 ms after `VimEnter`)" }
            )
        else
            local lang_count = cfg.languages and #cfg.languages or 0
            if lang_count > 0 then
                h.ok(("`tree-sitter-manager` · `%d` language(s) configured"):format(lang_count))
            else
                h.warn(
                    "`tree-sitter-manager` · no languages configured",
                    { "Add languages to the `tree-sitter-manager` setup in `plugin/tree-sitter-manager.lua`" }
                )
            end
        end
    end

    ::skip_tsm::

    --------------------------------------------------------------------
    -- Section 3: completions
    -- The completions utility relies on vim.lsp.completion (0.11+)
    --------------------------------------------------------------------
    h.start("Completions")

    if vim.lsp.completion then
        h.ok("`vim.lsp.completion` · available")
    else
        h.error("`vim.lsp.completion` · not available", { "Requires Neovim ≥ 0.11" })
    end

    --------------------------------------------------------------------
    -- Section 4: trigger the `health.lua` files of the submodules
    --------------------------------------------------------------------
    require("utils.conform.health").check()
    require("utils.floattui.health").check()
    require("utils.statusline.health").check()
end

return M
