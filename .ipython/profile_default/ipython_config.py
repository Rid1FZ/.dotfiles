import pygments.styles as pgstyles
import pygments.util
from IPython.core import ultratb

c = get_config()  # type: ignore

try:
    style = pgstyles.get_style_by_name("catppuccin-mocha")
except pygments.util.ClassNotFound:
    import importlib
    import shlex
    import subprocess

    print(f"\033[92m[INFO]:\033[00m theme not found. installing...")

    subprocess.run(shlex.split("python3 -m ensurepip"), stdout=subprocess.DEVNULL)
    subprocess.run(
        shlex.split("python3 -m pip install catppuccin[pygments]"),
        stdout=subprocess.DEVNULL,
    )

    print(f"\033[92m[INFO]:\033[00m theme installed")

    pgstyles = importlib.reload(pgstyles)
    style = pgstyles.get_style_by_name("catppuccin-mocha")

c.InteractiveShell.banner1 = ""
c.InteractiveShell.banner2 = ""
c.InteractiveShell.cache_size = 10000
c.InteractiveShell.colors = "lightbg"
c.TerminalInteractiveShell.colors = "lightbg"
c.TerminalInteractiveShell.display_completions = "column"
c.TerminalInteractiveShell.editing_mode = "emacs"
c.TerminalInteractiveShell.editor = "nvim"
c.TerminalInteractiveShell.highlight_matching_brackets = True
c.TerminalInteractiveShell.highlighting_style = style
c.TerminalInteractiveShell.true_color = True
ultratb.VerboseTB.tb_highlight = "bg:#8839ef"
