c = get_config()


def get_theme() -> str:
    """
    Try to register catppuccin-mocha as an IPython theme.
    Falls back to gruvbox-dark if unavailable.
    Returns the theme name to use.
    """

    from copy import deepcopy

    import pygments.styles as pgstyles
    from IPython.utils.PyColorize import linux_theme, theme_table

    catppuccin = "catppuccin-mocha"

    def _try_register() -> bool:
        try:
            # Ensure pygments can resolve the style
            pgstyles.get_style_by_name(catppuccin)

            # Register theme with IPython terminal formatter
            theme = deepcopy(linux_theme)
            theme.base = catppuccin

            theme_table[catppuccin] = theme

            return True

        except Exception:
            return False

    if _try_register():
        return catppuccin

    print("warning: catppuccin theme not found. Falling back to gruvbox-dark.")

    return "gruvbox-dark"


c.InteractiveShell.banner1 = ""
c.InteractiveShell.banner2 = ""
c.InteractiveShell.cache_size = 10000

c.TerminalInteractiveShell.auto_match = True
c.TerminalInteractiveShell.colors = get_theme()
c.TerminalInteractiveShell.display_completions = "column"
c.TerminalInteractiveShell.editing_mode = "emacs"
c.TerminalInteractiveShell.editor = "nvim"
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.true_color = True
