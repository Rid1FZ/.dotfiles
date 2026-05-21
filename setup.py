#!/bin/env python3

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
from collections.abc import Callable, Generator
from enum import Enum, auto
from pathlib import Path
from typing import Final, Literal, NotRequired, TypedDict, cast

SPECS: Spec = {
    "DOTFILES_DIR": "$HOME/Projects/dotfiles",
    "DOTFILES_REMOTE": "https://github.com/user/dotfiles.git",
    "TARGET_DIR": "$HOME",
    "SETUP": [
        {"CMD": ["sudo", "dnf", "update", "--assumeyes"]},
        {
            "COPY": {
                "SRC_GLOBS": [".local/share/applications/*"],
                "IGNORE_GLOBS": [],
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
        {
            "LINK": {
                "SRC_GLOBS": [".config/*"],
                "IGNORE_GLOBS": [".config/mimeapps.list"],
                "RECURSIVE": False,
                "IF_EXISTS": "backup",  # backup/remove/ignore
            }
        },
    ],
}


IfExists = Literal["backup", "remove", "ignore"]


class CopySpec(TypedDict):
    SRC_GLOBS: list[str]
    IGNORE_GLOBS: NotRequired[list[str]]
    IF_EXISTS: NotRequired[IfExists]


class LinkSpec(TypedDict):
    SRC_GLOBS: list[str]
    IGNORE_GLOBS: NotRequired[list[str]]
    RECURSIVE: NotRequired[bool]
    IF_EXISTS: NotRequired[IfExists]


class CmdStep(TypedDict):
    CMD: list[str]


class CopyStep(TypedDict):
    COPY: CopySpec


class LinkStep(TypedDict):
    LINK: LinkSpec


SetupStep = CmdStep | CopyStep | LinkStep


class Spec(TypedDict):
    DOTFILES_DIR: str
    DOTFILES_REMOTE: str
    TARGET_DIR: str
    SETUP: list[SetupStep]


_VALID_IF_EXISTS: frozenset[str] = frozenset({"backup", "remove", "ignore"})


class DotfilesError(Exception):
    """Base exception for all bootstrapper errors."""


class ConfigError(DotfilesError):
    """Malformed or invalid SPECS config."""


class FileOperationError(DotfilesError):
    """Failure during a file/directory copy, link, backup, or removal."""


class CommandError(DotfilesError):
    """A subprocess command exited non-zero or failed to launch."""


class LogLevel(Enum):
    INFO = auto()
    SUCCESS = auto()
    WARNING = auto()
    ERROR = auto()
    DEBUG = auto()


class Logger:
    _BOLD: Final[str] = "\033[1m"  # ]
    _RESET: Final[str] = "\033[0m"  # ]
    _COLORS: Final[dict[LogLevel, str]] = {
        LogLevel.INFO: "\033[94m",  # ] blue
        LogLevel.SUCCESS: "\033[92m",  # ] green
        LogLevel.WARNING: "\033[93m",  # ] yellow
        LogLevel.ERROR: "\033[91m",  # ] red
        LogLevel.DEBUG: "\033[95m",  # ] magenta
    }
    _STDERR_LEVELS: Final[frozenset[LogLevel]] = frozenset(
        (
            LogLevel.WARNING,
            LogLevel.ERROR,
            LogLevel.DEBUG,
        )
    )

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


class HinderCache:
    def __init__(self, fn: Callable[[Path], str | None]) -> None:
        self._fn: Callable[[Path], str | None] = fn
        self._cache: dict[Path, str | None] = {}

    def __call__(self, path: Path) -> str | None:
        if path in self._cache:
            return self._cache[path]

        for ancestor in path.parents:
            if ancestor not in self._cache:
                continue

            cached = self._cache[ancestor]
            if cached is not None:  # A hinder
                self._cache[path] = cached
                return cached
            break

        result = self._fn(path)
        self._cache[path] = result
        return result

    def invalidate(self, path: Path) -> None:
        stale = [k for k in self._cache if k == path or path in k.parents]
        for k in stale:
            del self._cache[k]


@HinderCache
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
    if dry_run:
        Logger.info(f"[dry-run] Would remove: {path}")
        return

    try:
        if isfile(path) or islink(path) or isbrokenlink(path):
            path.unlink(missing_ok=True)
        elif isdir(path):
            shutil.rmtree(path)
    except OSError as e:
        raise FileOperationError(f"Failed to remove {path}: {e}") from e

    if verbose:
        Logger.success(f"Removed: {path}")


def _resolve_backup_path(path: Path) -> Path:
    """
    Returns the next available backup path for the given path using an
    incrementing numeric suffix: <name>_1.bak, <name>_2.bak, ...
    """
    n = 1
    while True:
        candidate = path.parent / f"{path.name}_{n}.bak"
        if not exists(candidate):
            return candidate
        n += 1


def make_backup(
    path: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    if not exists(path):
        return

    backup_path = _resolve_backup_path(path)

    if dry_run:
        Logger.info(f"[dry-run] Would backup: {path!s} -> {backup_path!s}")
        return

    try:
        path.rename(backup_path)
    except OSError as e:
        raise FileOperationError(
            f"Failed to backup {path} -> {backup_path}: {e}"
        ) from e

    if verbose:
        Logger.success(f"Backed up: {path!s} -> {backup_path!s}")


def _remove_hindrance(
    path: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    if hinder := get_hinder(path):
        remove_path(Path(hinder), verbose=verbose, dry_run=dry_run)
        get_hinder.invalidate(Path(hinder))


def _clear_hinder(
    dst: Path,
    if_exists: str,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> bool:
    """
    Resolves anything in the path to dst that would block its creation
    (a non-directory component such as a regular file or broken symlink).

    Returns False if the caller should skip this destination entirely.
    """
    if hinder := get_hinder(dst):
        match if_exists:
            case "ignore":
                Logger.error(f"Skipping {dst}: blocked by {hinder}")
                return False
            case "remove":
                _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(Path(hinder), verbose=verbose, dry_run=dry_run)
                get_hinder.invalidate(Path(hinder))
            case _:
                raise ConfigError(f"Invalid value for `if_exists`: {if_exists!r}")
    return True


def _clear_existing(
    dst: Path,
    if_exists: str,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> bool:
    """
    Resolves dst itself already existing (e.g. a leftover directory).

    Returns False if the caller should skip this destination entirely.
    """
    if exists(dst):
        match if_exists:
            case "ignore":
                if verbose:
                    Logger.debug(f"Skipping (already exists): {dst}")
                return False
            case "remove":
                remove_path(dst, verbose=verbose, dry_run=dry_run)
            case "backup":
                make_backup(dst, verbose=verbose, dry_run=dry_run)
            case _:
                raise ConfigError(f"Invalid value for `if_exists`: {if_exists!r}")
    return True


def _walk_dir(
    src: Path,
    ignore: set[Path],
    *,
    verbose: bool = False,
) -> Generator[Path, None, None]:
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

    if not _clear_hinder(dst, if_exists, verbose=verbose, dry_run=dry_run):
        return
    if not _clear_existing(dst, if_exists, verbose=verbose, dry_run=dry_run):
        return

    if dry_run:
        Logger.info(f"[dry-run] Would copy: {src} -> {dst}")
        return

    try:
        os.makedirs(dst.parent, exist_ok=True)
        if rebuild_symlinks and (islink(src) or isbrokenlink(src)):
            dst.symlink_to(src.readlink().absolute())
        else:
            shutil.copyfile(src, dst, follow_symlinks=False)
    except OSError as e:
        raise FileOperationError(f"Failed to copy {src} -> {dst}: {e}") from e

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

    # Only check for hindrances; an existing destination directory is intentionally
    # entered rather than replaced — individual files handle their own if_exists policy.
    if not _clear_hinder(dst, if_exists, verbose=verbose, dry_run=dry_run):
        return

    if dry_run:
        Logger.info(f"[dry-run] Would create: {dst}")
    else:
        try:
            os.makedirs(dst, exist_ok=True)
        except OSError as e:
            raise FileOperationError(f"Failed to create directory {dst}: {e}") from e
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

    if not _clear_hinder(dst, if_exists, verbose=verbose, dry_run=dry_run):
        return
    if not _clear_existing(dst, if_exists, verbose=verbose, dry_run=dry_run):
        return

    if dry_run:
        Logger.info(f"[dry-run] Would link: {dst} -> {src.absolute()}")
        return

    try:
        os.makedirs(dst.parent, exist_ok=True)
        dst.symlink_to(src.absolute())
    except OSError as e:
        raise FileOperationError(
            f"Failed to link {dst} -> {src.absolute()}: {e}"
        ) from e

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

    if dry_run:
        Logger.info(f"[dry-run] Would run cmd: {cmd_string}")
        return

    if verbose:
        Logger.info(f"Running cmd: {cmd_string}")

    try:
        subprocess.run(
            args,
            shell=True,
            capture_output=True,
            check=True,
            text=True,
            errors="replace",
        )
    except FileNotFoundError:
        raise CommandError(f"Command not found: {args[0]!r}") from None
    except subprocess.CalledProcessError as e:
        stderr = e.stderr.strip()
        raise CommandError(f"Command failed: {cmd_string}\n{stderr}") from e

    if verbose:
        Logger.success(f"Command succeeded: {cmd_string}")


def _make_state_path() -> Callable[[], Path]:
    path = (
        Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"))
        / "dotfiles-bootstrap"
        / "state.json"
    )
    return lambda: path


_state_path: Callable[[], Path] = _make_state_path()


def _load_state() -> int:
    try:
        data = json.loads(_state_path().read_text())
        return int(data["next_step"])
    except (FileNotFoundError, KeyError, ValueError, json.JSONDecodeError):
        return 0


def _save_state(next_step: int) -> None:
    path = _state_path()
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"next_step": next_step}))
    except OSError as e:
        Logger.warn(f"Could not save resume state: {e}")


def _clear_state() -> None:
    try:
        _state_path().unlink(missing_ok=True)
    except OSError as e:
        Logger.warn(f"Could not clear resume state: {e}")


def dispatch(
    specs: Spec,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    from_start: bool = False,
) -> None:
    # fmt: off
    dotfiles_dir = Path(os.path.expandvars(cast(str, specs["DOTFILES_DIR"]))).expanduser()
    target_dir = Path(os.path.expandvars(cast(str, specs["TARGET_DIR"]))).expanduser()
    # fmt: on

    for i, item in enumerate(specs["SETUP"]):
        action, value = next(iter(item.items()))
        if action in ("COPY", "LINK"):
            if_exists = cast(CopySpec | LinkSpec, value).get("IF_EXISTS", "ignore")
            if if_exists not in _VALID_IF_EXISTS:
                raise ConfigError(
                    f"Step {i + 1}: invalid IF_EXISTS value {if_exists!r}; "
                    + f"must be one of {sorted(_VALID_IF_EXISTS)}"
                )

    start_from = 0 if from_start else _load_state()

    if start_from > 0:
        Logger.info(
            f"Resuming from step {start_from + 1}, "
            + f"skipping step{'s' if start_from > 1 else ''} "
            + f"1{'–' + str(start_from) if start_from > 1 else ''}."
        )

    for i, item in enumerate(specs["SETUP"]):
        if i < start_from:
            continue

        action, value = next(iter(item.items()))

        try:
            match action:
                case "CMD":
                    run_command(
                        cast(list[str], value),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case "COPY":
                    v = cast(CopySpec, value)
                    copy(
                        v["SRC_GLOBS"],
                        target_dir,
                        dotfiles_dir,
                        ignore_globs=v.get("IGNORE_GLOBS"),
                        if_exists=v.get("IF_EXISTS", "ignore"),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case "LINK":
                    v = cast(LinkSpec, value)
                    link(
                        v["SRC_GLOBS"],
                        target_dir,
                        dotfiles_dir,
                        ignore_globs=v.get("IGNORE_GLOBS"),
                        recursive=v.get("RECURSIVE", False),
                        if_exists=v.get("IF_EXISTS", "ignore"),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case _:
                    raise ConfigError(f"Step {i + 1}: unknown action {action!r}")

        except DotfilesError:
            _save_state(i)
            raise

    _clear_state()


class CliArgs(argparse.Namespace):
    from_start: bool = False
    verbose: bool = False
    dry_run: bool = False


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bootstrap a dotfiles repository.",
    )
    parser.add_argument(
        "--from1",
        action="store_true",
        dest="from_start",
        help="Start from step 1, ignoring any saved resume state.",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        dest="dry_run",
        help="Print what would be done without making any changes.",
    )
    args = parser.parse_args(namespace=CliArgs())

    try:
        dispatch(
            SPECS,
            verbose=args.verbose,
            dry_run=args.dry_run,
            from_start=args.from_start,
        )
    except DotfilesError as e:
        Logger.error(str(e))
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())


# pyright: basic
