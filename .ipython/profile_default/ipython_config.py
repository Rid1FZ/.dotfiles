import importlib
import subprocess
import sys

from IPython.core import ultratb

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
        "info": ("\033[92m", "[INFO]"),  # green
        "warn": ("\033[93m", "[WARN]"),  # yellow
        "error": ("\033[91m", "[ERROR]"),  # red
        "success": ("\033[96m", "[OK]"),  # cyan
        "debug": ("\033[95m", "[DEBUG]"),  # magenta
    }
    _reset = "\033[0m"
    color, label = _styles.get(level, _styles["info"])
    print(f"{color}{label}{_reset} {msg}", file=sys.stderr)


def _resolve_style():
    """
    1. Try to load catppuccin-mocha directly.
    2. If missing, attempt a silent pip install and reload pygments' entry-point cache.
    3. If the install or second load fails, fall back to one-dark.
    4. If one-dark is also missing, return None and let IPython use its default.
    """
    import pygments.styles as pgstyles
    import pygments.util

    # attempt: 1
    try:
        return pgstyles.get_style_by_name("catppuccin-mocha")
    except pygments.util.ClassNotFound:
        _print("catppuccin theme not found. Attempting install…")

    # attempt: 2
    try:
        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "--quiet", "catppuccin[pygments]"],
        )
        importlib.invalidate_caches()
        importlib.reload(pgstyles)

        return pgstyles.get_style_by_name("catppuccin-mocha")
    except Exception:
        _print("Install failed or style still not found.", level="warn")

    # attempt: 3
    try:
        return pgstyles.get_style_by_name("one-dark")
    except pygments.util.ClassNotFound:
        _print("one-dark not found either. Using IPython default.", level="warn")
        return None


_style = _resolve_style()


c.InteractiveShell.banner1 = ""
c.InteractiveShell.banner2 = ""
c.InteractiveShell.cache_size = 10000


c.TerminalInteractiveShell.auto_match = True  # added in IPython 8.x
c.TerminalInteractiveShell.display_completions = "column"
c.TerminalInteractiveShell.editing_mode = "emacs"
c.TerminalInteractiveShell.editor = "nvim"
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.true_color = True

if _style is not None:
    c.TerminalInteractiveShell.highlighting_style = _style

# Direct attribute assignment on VerboseTB is fragile; guard it so a future
# IPython version that removes the attribute doesn't break startup.
try:
    ultratb.VerboseTB.tb_highlight = "bg:#8839ef"
except AttributeError:
    _print("could not access ultratb.VerboseTB.tb_highlight", "error")
