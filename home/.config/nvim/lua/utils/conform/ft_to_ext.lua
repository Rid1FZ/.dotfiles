-- Filetype-to-extension map used only when formatting an unnamed buffer,
-- so that $FILENAME has a sensible extension for language detection.
---@type table<string, string>
return {
    elixir = "ex",
    graphql = "gql",
    javascript = "js",
    javascriptreact = "jsx",
    markdown = "md",
    perl = "pl",
    python = "py",
    ruby = "rb",
    rust = "rs",
    typescript = "ts",
    typescriptreact = "tsx",
}
