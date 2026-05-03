import subprocess
import sys
from copy import deepcopy

from IPython.utils.PyColorize import linux_theme, theme_table

c = get_config()  # type: ignore


def _print(msg: str, level: str = "info") -> None:
    """
    Print a styled message to stderr.

    Levels:
        info    → green   [INFO]
        warn    → yellow  [WARN]
        error   → red     [ERROR]
        success → cyan    [OK]
        debug   → magenta [DEBUG]
    """
    _styles = {
        "info": ("\033[92m", "[INFO]"),
        "warn": ("\033[93m", "[WARN]"),
        "error": ("\033[91m", "[ERROR]"),
        "success": ("\033[96m", "[OK]"),
        "debug": ("\033[95m", "[DEBUG]"),
    }
    _reset = "\033[0m"
    color, label = _styles.get(level, _styles["info"])
    print(f"{color}{label}{_reset} {msg}", file=sys.stderr)


def get_theme() -> str:
    """
    Try to register catppuccin-mocha as an IPython theme.
    Falls back to gruvbox-dark if unavailable.
    Returns the theme name to use.
    """
    import importlib

    import pygments.styles as pgstyles
    import pygments.util

    catppuccin = "catppuccin-mocha"

    def _try_register() -> bool:
        try:
            pgstyles.get_style_by_name(catppuccin)  # validate
            theme = deepcopy(linux_theme)
            theme.base = catppuccin
            theme_table[catppuccin] = theme
            return True
        except pygments.util.ClassNotFound:
            return False

    if _try_register():
        return catppuccin

    _print("catppuccin theme not found. Attempting install…")
    try:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "catppuccin[pygments]"],
        )
        importlib.invalidate_caches()
        importlib.reload(pgstyles)
        if _try_register():
            return catppuccin
    except Exception:
        pass

    _print("Install failed. Falling back to gruvbox-dark.", level="warn")
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
