#!/bin/env python3

import os
import shutil
import subprocess
import sys
from enum import Enum, auto
from functools import cache
from pathlib import Path

SPECS: dict = {
    "DOTFILES_DIR": "$HOME/.dotfiles",
    "DOTFILES_REMOTE": "https://github.com/user/dotfiles.git",
    "TARGET_DIR": "$HOME",
    "SETUP": [
        {"CMD": ["dnf", "update", "--assumeyes"]},
        {
            "COPY": {
                "SRC_GLOBS": [".local/share/applications/*"],
                "IGNORE_GLOBS": [".local/share/applications/nvim.desktop"],
                "IF_EXISTS": "backup",  # backup/remove/ignore
            }
        },
        {
            "LINK": {
                "SRC_GLOBS": [".local/bin/*"],
                "IGNORE_GLOBS": [],
                "RECURSIVE": False,
                "IF_EXISTS": "backup",  # backup/remove/ignore
            }
        },
        {"CMD": ["systemctl", "--user", "enable", "--now", "syncthing"]},
    ],
}


class LogLevel(Enum):
    INFO = auto()
    SUCCESS = auto()
    WARNING = auto()
    ERROR = auto()
    DEBUG = auto()


class Logger:
    _BOLD = "\033[1m"  # ]
    _RESET = "\033[0m"  # ]
    _COLORS: dict[LogLevel, str] = {
        LogLevel.INFO: "\033[94m",  # ] blue
        LogLevel.SUCCESS: "\033[92m",  # ] green
        LogLevel.WARNING: "\033[93m",  # ] yellow
        LogLevel.ERROR: "\033[91m",  # ] red
        LogLevel.DEBUG: "\033[95m",  # ] magenta
    }
    _STDERR_LEVELS = {LogLevel.WARNING, LogLevel.ERROR, LogLevel.DEBUG}

    @classmethod
    def _format(cls, message: str, level: LogLevel) -> str:
        return f"{cls._BOLD}{cls._COLORS[level]}[{level.name}]{cls._RESET} {message}"

    @classmethod
    def log(cls, message: str, level: LogLevel = LogLevel.INFO) -> None:
        stream = sys.stderr if level in cls._STDERR_LEVELS else sys.stdout
        print(cls._format(message, level), file=stream)

    @classmethod
    def info(cls, message: str) -> None:
        cls.log(message, LogLevel.INFO)

    @classmethod
    def success(cls, message: str) -> None:
        cls.log(message, LogLevel.SUCCESS)

    @classmethod
    def warn(cls, message: str) -> None:
        cls.log(message, LogLevel.WARNING)

    @classmethod
    def error(cls, message: str) -> None:
        cls.log(message, LogLevel.ERROR)

    @classmethod
    def debug(cls, message: str) -> None:
        cls.log(message, LogLevel.DEBUG)


def exists(path: Path) -> bool:
    """
    Checks whether the specified path exists, including broken symlinks.
    """
    return path.exists() or path.is_symlink()


def isfile(path: Path) -> bool:
    """
    Checks whether the given path is a regular file and not a symbolic link.
    """
    return path.is_file() and not path.is_symlink()


def isdir(path: Path) -> bool:
    """
    Checks whether the given path is a directory and not a symbolic link.
    """
    return path.is_dir() and not path.is_symlink()


def isbrokenlink(path: Path) -> bool:
    """
    Checks whether the given path is a broken symbolic link.
    """
    # if path is a broken link, Path.exists will return False. We will use this feature
    return path.is_symlink() and not path.exists()


def islink(path: Path) -> bool:
    """
    Checks whether the given path is a valid (non-broken) symbolic link.
    """
    return path.is_symlink() and not isbrokenlink(path)


def islinkf(path: Path) -> bool:
    """
    Checks whether the given path is a symbolic link that points to a regular file.
    """
    return path.is_symlink() and path.is_file()


def islinkd(path: Path) -> bool:
    """
    Checks whether the given path is a symbolic link that points to a directory.
    """
    return path.is_symlink() and path.is_dir()


@cache
def get_hinder(path: Path) -> str | None:
    """
    Recursively identifies the nearest path component that would prevent file or directory creation.

    This function checks if any part of the given path is a broken symlink or a non-directory
    (excluding valid directory symlinks). It traverses up the path hierarchy until it either
    finds such a hindrance or reaches the root.
    """
    if str(path) == "/":
        return None

    if isbrokenlink(path):
        return str(path)

    if isdir(path) or islinkd(path):
        return None

    if not exists(path):
        return get_hinder(path.parent)

    # Path exists but is not a directory (e.g. a regular file or a symlink to a
    # file).  It blocks the creation of anything beneath it.
    return str(path)


def remove_path(
    path: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    """
    Recursively removes a file, directory, or (broken) symbolic link at the specified path.

    This function safely deletes the given path. It handles:
      - regular files
      - symbolic links (including broken links)
      - directories (recursively)

    If the path does not exist, it silently ignores the error.
    """
    try:
        if dry_run:
            Logger.info(f"[dry-run] Would remove: {path}")
            return

        if verbose:
            Logger.debug(f"removing {path}")

        if isfile(path) or islink(path) or isbrokenlink(path):
            path.unlink(missing_ok=True)
        elif isdir(path):
            shutil.rmtree(path)

        if verbose:
            Logger.success(f"removed {path}")

    except FileNotFoundError:
        if verbose:
            Logger.error(f"failed to remove {path}: file not found")


def _resolve_name(path: Path) -> str:
    from datetime import datetime

    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

    return path.name + "_" + timestamp + ".bak"


def make_backup(
    path: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    if not exists(path):
        return

    backup_name = _resolve_name(path)
    backup_path = path.parent / backup_name

    if verbose:
        Logger.info(f"Backing up: {path!s} -> {backup_path!s}")

    if dry_run:
        Logger.info(f"[dry-run] Would backup: {path!s} -> {backup_path!s}")
        return

    path.rename(str(backup_path))


def _remove_hindrance(
    path: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    if hinder := get_hinder(path):
        remove_path(Path(hinder), verbose=verbose, dry_run=dry_run)
        get_hinder.cache_clear()


def _walk_dir(
    src: Path,
    ignore: set[Path],
    *,
    verbose: bool = False,
):
    for root, dirs, files in src.walk():
        dirs[:] = [d for d in dirs if root / d not in ignore]
        for file in files:
            f = root / file
            if f in ignore:
                if verbose:
                    Logger.debug(f"Skipping (ignored): {f}")
                continue
            yield f


def _copy_file(
    src: Path,
    dest_dir: Path,
    dotfiles_dir: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        match if_exists:
            case "ignore":
                Logger.error(f"Skipping {dst}: blocked by {hinder}")
                return
            case "remove":
                _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(Path(hinder), verbose=verbose, dry_run=dry_run)
                get_hinder.cache_clear()
            case _:
                Logger.error(f"Invalid value for `if_exists`: {if_exists!r}")
                return

    if exists(dst):
        match if_exists:
            case "ignore":
                if verbose:
                    Logger.debug(f"Skipping (already exists): {dst}")
                return
            case "remove":
                remove_path(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(dst, verbose=verbose, dry_run=dry_run)

    if dry_run:
        Logger.info(f"[dry-run] Would copy: {src} -> {dst}")
        return

    os.makedirs(dst.parent, exist_ok=True)

    if rebuild_symlinks and (islink(src) or isbrokenlink(src)):
        dst.symlink_to(src.readlink().absolute())
    else:
        shutil.copyfile(src, dst, follow_symlinks=False)

    if verbose:
        Logger.success(f"Copied: {src} -> {dst}")


def _copy_dir(
    src: Path,
    dest_dir: Path,
    dotfiles_dir: Path,
    ignore: set[Path],
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        match if_exists:
            case "ignore":
                Logger.error(f"Skipping {dst}: blocked by {hinder}")
                return
            case "remove":
                _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(dst, verbose=verbose, dry_run=dry_run)
            case _:
                Logger.error("invalid input for `if_exists`")
                return

    if dry_run:
        Logger.info(f"[dry-run] Would create: {dst}")
    else:
        os.makedirs(dst, exist_ok=True)
        if verbose:
            Logger.success(f"Created: {dst}")

    for f in _walk_dir(src, ignore, verbose=verbose):
        _copy_file(
            f,
            dest_dir,
            dotfiles_dir,
            verbose=verbose,
            dry_run=dry_run,
            if_exists=if_exists,
            rebuild_symlinks=rebuild_symlinks,
        )


def copy(
    srcs: list[str],
    dest_dir: Path,
    dotfiles_dir: Path,
    *,
    ignore_globs: list[str] | None = None,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    dotfiles_dir = dotfiles_dir.absolute()
    expanded_ignore_globs = {
        match for glob in (ignore_globs or []) for match in dotfiles_dir.rglob(glob)
    }
    expanded_srcs = (match for glob in srcs for match in dotfiles_dir.glob(glob))

    for src in expanded_srcs:
        if src in expanded_ignore_globs:
            if verbose:
                Logger.debug(f"Skipping (ignored): {src}")
            continue

        if isfile(src) or islink(src) or isbrokenlink(src):
            _copy_file(
                src,
                dest_dir,
                dotfiles_dir,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
                rebuild_symlinks=rebuild_symlinks,
            )
            continue

        _copy_dir(
            src,
            dest_dir,
            dotfiles_dir,
            expanded_ignore_globs,
            verbose=verbose,
            dry_run=dry_run,
            if_exists=if_exists,
            rebuild_symlinks=rebuild_symlinks,
        )


def _link_entry(
    src: Path,
    dest_dir: Path,
    dotfiles_dir: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        match if_exists:
            case "ignore":
                Logger.error(f"Skipping {dst}: blocked by {hinder}")
                return
            case "remove":
                _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(Path(hinder), verbose=verbose, dry_run=dry_run)
                get_hinder.cache_clear()
            case _:
                Logger.error(f"Invalid value for `if_exists`: {if_exists!r}")
                return

    if exists(dst):
        match if_exists:
            case "ignore":
                if verbose:
                    Logger.debug(f"Skipping (already exists): {dst}")
                return
            case "remove":
                remove_path(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(dst, verbose=verbose, dry_run=dry_run)

    if dry_run:
        Logger.info(f"[dry-run] Would link: {dst} -> {src.absolute()}")
        return

    os.makedirs(dst.parent, exist_ok=True)
    dst.symlink_to(src.absolute())

    if verbose:
        Logger.success(f"Linked: {dst} -> {src.absolute()}")


def link(
    srcs: list[str],
    dest_dir: Path,
    dotfiles_dir: Path,
    *,
    ignore_globs: list[str] | None = None,
    recursive: bool = False,
    if_exists: str = "ignore",
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    dotfiles_dir = dotfiles_dir.absolute()
    expanded_ignore_globs = {
        match for glob in (ignore_globs or []) for match in dotfiles_dir.rglob(glob)
    }
    expanded_srcs = (match for glob in srcs for match in dotfiles_dir.glob(glob))

    for src in expanded_srcs:
        if src in expanded_ignore_globs:
            if verbose:
                Logger.debug(f"Skipping (ignored): {src}")
            continue

        if not recursive or isfile(src) or islink(src) or isbrokenlink(src):
            _link_entry(
                src,
                dest_dir,
                dotfiles_dir,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
            )
            continue

        for f in _walk_dir(src, expanded_ignore_globs, verbose=verbose):
            _link_entry(
                f,
                dest_dir,
                dotfiles_dir,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
            )


def run_command(
    args: list[str],
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    cmd_string = " ".join(args)

    if verbose:
        Logger.info(f"running cmd: {cmd_string}")

    if dry_run:
        Logger.info(f"[dry-run] would run cmd: {cmd_string}")
        return

    try:
        subprocess.run(
            args,
            shell=False,
            capture_output=True,
            check=True,
        )
    except subprocess.CalledProcessError as e:
        Logger.error(f"failed to run {cmd_string}: {e.stderr}")


def dispatch(
    specs: dict,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    dotfiles_dir = Path(os.path.expandvars(specs["DOTFILES_DIR"])).expanduser()
    target_dir = Path(os.path.expandvars(specs["TARGET_DIR"])).expanduser()

    for item in specs["SETUP"]:
        action, value = next(iter(item.items()))

        match action:
            case "CMD":
                run_command(value, verbose=verbose, dry_run=dry_run)

            case "COPY":
                copy(
                    value["SRC_GLOBS"],
                    target_dir,
                    dotfiles_dir,
                    ignore_globs=value.get("IGNORE_GLOBS"),
                    if_exists=value.get("IF_EXISTS", "ignore"),
                    verbose=verbose,
                    dry_run=dry_run,
                )

            case "LINK":
                link(
                    value["SRC_GLOBS"],
                    target_dir,
                    dotfiles_dir,
                    ignore_globs=value.get("IGNORE_GLOBS"),
                    recursive=value.get("RECURSIVE", False),
                    if_exists=value.get("IF_EXISTS", "ignore"),
                    verbose=verbose,
                    dry_run=dry_run,
                )


def main() -> int:
    return 0


if __name__ == "__main__":
    sys.exit(main())
