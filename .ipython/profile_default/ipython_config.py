from IPython.core import ultratb
import pygments.styles
import pygments.util

c = get_config()  # type: ignore

try:
    style = pygments.styles.get_style_by_name("catppuccin-mocha")
except pygments.util.ClassNotFound:
    import subprocess
    import importlib

    subprocess.call(
        ["python3", "-m", "ensurepip"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    subprocess.call(
        ["python3", "-m", "pip", "install", "catppuccin[pygments]"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    pygments.styles = importlib.reload(pygments.styles)
    pygments.util = importlib.reload(pygments.util)
    style = pygments.styles.get_style_by_name("catppuccin-mocha")

c.InteractiveShell.banner1 = ""
c.InteractiveShell.banner2 = ""
c.InteractiveShell.cache_size = 10000
c.InteractiveShell.colors = "LightBG"
c.TerminalInteractiveShell.colors = "LightBG"
c.TerminalInteractiveShell.display_completions = "column"
c.TerminalInteractiveShell.editing_mode = "emacs"
c.TerminalInteractiveShell.editor = "/bin/nvim"
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.highlighting_style = style
ultratb.VerboseTB._tb_highlight = "bg:#1a1b26"
