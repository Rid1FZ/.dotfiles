return {
    filetype = { "python" },
    priority = 1,
    command = "ruff",
    args = { "check", "--select", "I", "--fix", "--stdin-filename", "$FILENAME", "--quiet", "-" },
    root_markers = { ".isort.cfg", "pyproject.toml", "setup.py", "setup.cfg", "tox.ini", ".editorconfig", ".git" },
}
