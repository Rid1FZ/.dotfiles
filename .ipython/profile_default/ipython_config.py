import pygments.styles as pgstyles
import pygments.util
from IPython.core import ultratb

c = get_config()  # type: ignore

try:
    style = pgstyles.get_style_by_name("catppuccin-mocha")
except pygments.util.ClassNotFound:
    print(
        f"\033[92m[INFO]:\033[00m catppuccin theme not found. Using one-dark...\n\n"
        "run `python3 -m pip install catppuccin[pygments]` to install theme..."
    )
    style = pgstyles.get_style_by_name("one-dark")

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
