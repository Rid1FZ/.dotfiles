return {
    filetype = { "tex", "plaintex" },
    priority = 1,
    command = "latexindent",
    args = { "-" },
    root_markers = { ".git", ".latexmkrc", "latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml" },
}
