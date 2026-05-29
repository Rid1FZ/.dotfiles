#!/usr/bin/env python3
"""
Dotfiles bootstrapper — deploys a dotfiles repository to the specified directory according
to the SPECS configuration dict. Supports copy, symlink, and command steps, with dry-run,
verbose output, resume-on-failure, and a runtime dotfiles directory override.

:license: WTFPL – Do What the Fuck You Want to Public License
"""

from __future__ import annotations

__author__ = "Ridwan Faiz"
__license__ = "WTFPL"


import argparse
import json
import os
import shutil
import subprocess
import sys
import types
import typing
from collections.abc import Callable, Generator
from enum import Enum, auto
from pathlib import Path
from typing import (
    Any,
    Final,
    Literal,
    NotRequired,
    TypedDict,
    Union,
)

# ── SPECS ─────────────────────────────────────────────────────────────────────

SPECS: Spec = {
    "DOTFILES_DIR": "$HOME/Projects/dotfiles",
    "DOTFILES_REMOTE": "https://github.com/user/dotfiles.git",
    "TARGET_DIR": "$HOME",
    "SETUP": [
        {
            "COPY": {
                "SRC_GLOBS": [
                    ".config/mimeapps.list",
                    ".local/share/applications/*",
                    ".local/share/backgrounds/*",
                ],
                "IGNORE_GLOBS": [],
                "SRC_ROOT": "home",
                "IF_EXISTS": "backup",
            }
        },
        {
            "LINK": {
                "SRC_GLOBS": [
                    ".bash_profile",
                    ".bashrc",
                    ".zprofile",
                    ".zshrc",
                    ".ipython",
                    ".config/*",
                    ".local/bin/*",
                ],
                "IGNORE_GLOBS": [".config/mimeapps.list"],
                "SRC_ROOT": "home",
                "RECURSIVE": False,
                "IF_EXISTS": "backup",
            }
        },
    ],
}


# ── Type definitions ──────────────────────────────────────────────────────────

IfExists = Literal["backup", "remove", "ignore"]
"""Valid values for the IF_EXISTS field in COPY and LINK steps."""


class CopySpec(TypedDict):
    """Configuration for a COPY step."""

    SRC_GLOBS: list[str]
    SRC_ROOT: NotRequired[str]
    IGNORE_GLOBS: NotRequired[list[str]]
    IF_EXISTS: NotRequired[IfExists]


class LinkSpec(TypedDict):
    """Configuration for a LINK step."""

    SRC_GLOBS: list[str]
    SRC_ROOT: NotRequired[str]
    IGNORE_GLOBS: NotRequired[list[str]]
    RECURSIVE: NotRequired[bool]
    IF_EXISTS: NotRequired[IfExists]


class CmdStep(TypedDict):
    """A step that runs a shell command."""

    CMD: str


class CopyStep(TypedDict):
    """A step that copies files from the dotfiles directory."""

    COPY: CopySpec


class LinkStep(TypedDict):
    """A step that creates symlinks pointing into the dotfiles directory."""

    LINK: LinkSpec


SetupStep = CmdStep | CopyStep | LinkStep
"""A single setup step; exactly one action key (CMD, COPY, or LINK) per dict."""


class Spec(TypedDict):
    """Top-level SPECS configuration."""

    DOTFILES_DIR: str
    DOTFILES_REMOTE: str
    TARGET_DIR: str
    SETUP: list[SetupStep]


# ── Exceptions ────────────────────────────────────────────────────────────────


class DotfilesError(Exception):
    """Base exception for all bootstrapper errors."""


class ConfigError(DotfilesError):
    """Raised for malformed or invalid SPECS configuration."""


class FileOperationError(DotfilesError):
    """Raised when a file system operation (copy, link, backup, or removal) fails."""


class CommandError(DotfilesError):
    """Raised when a subprocess command exits non-zero or cannot be launched."""


# ── Logging ───────────────────────────────────────────────────────────────────


class LogLevel(Enum):
    INFO = auto()
    SUCCESS = auto()
    WARNING = auto()
    ERROR = auto()
    DEBUG = auto()


class Logger:
    """Coloured, levelled logger. Warnings, errors, and debug output go to stderr."""

    _BOLD: Final[str] = "\033[1m"  # ]
    _RESET: Final[str] = "\033[0m"  # ]
    # fmt: off
    _COLORS: Final[dict[LogLevel, str]] = {
        LogLevel.INFO:    "\033[94m",  # ] blue
        LogLevel.SUCCESS: "\033[92m",  # ] green
        LogLevel.WARNING: "\033[93m",  # ] yellow
        LogLevel.ERROR:   "\033[91m",  # ] red
        LogLevel.DEBUG:   "\033[95m",  # ] magenta
    }
    # fmt: on
    _STDERR_LEVELS: Final[frozenset[LogLevel]] = frozenset(
        {
            LogLevel.WARNING,
            LogLevel.ERROR,
            LogLevel.DEBUG,
        }
    )

    @classmethod
    def _format(cls, message: str, level: LogLevel) -> str:
        return f"{cls._BOLD}{cls._COLORS[level]}[{level.name}]{cls._RESET} {message}"  # fmt: skip

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


# ── Path utilities ────────────────────────────────────────────────────────────


def exists(path: Path) -> bool:
    """Return True if path exists, including broken symlinks."""
    return path.exists() or path.is_symlink()


def isfile(path: Path) -> bool:
    """Return True if path is a regular file (not a symlink)."""
    return path.is_file() and not path.is_symlink()


def isdir(path: Path) -> bool:
    """Return True if path is a directory (not a symlink)."""
    return path.is_dir() and not path.is_symlink()


def isbrokenlink(path: Path) -> bool:
    """Return True if path is a broken symbolic link."""
    return path.is_symlink() and not path.exists()


def islink(path: Path) -> bool:
    """Return True if path is a valid (non-broken) symbolic link."""
    return path.is_symlink() and not isbrokenlink(path)


def islinkf(path: Path) -> bool:
    """Return True if path is a symbolic link pointing to a regular file."""
    return path.is_symlink() and path.is_file()


def islinkd(path: Path) -> bool:
    """Return True if path is a symbolic link pointing to a directory."""
    return path.is_symlink() and path.is_dir()


# ── Hinder cache ──────────────────────────────────────────────────────────────


class HinderCache:
    """
    Callable cache for get_hinder with targeted per-path invalidation.

    Caches hinder results per path and short-circuits lookups when a cached ancestor
    is already known to be a hinder, avoiding redundant upward traversal.
    """

    def __init__(self, fn: Callable[[Path], str | None]) -> None:
        self._fn = fn
        self._cache: dict[Path, str | None] = {}

    def __call__(self, path: Path) -> str | None:
        if path in self._cache:
            return self._cache[path]

        for ancestor in path.parents:
            if ancestor not in self._cache:
                continue
            cached = self._cache[ancestor]
            if cached is not None:
                # Ancestor is a confirmed hinder; all descendants share it.
                self._cache[path] = cached
                return cached
            break

        result = self._fn(path)
        self._cache[path] = result
        return result

    def invalidate(self, path: Path) -> None:
        """Remove cache entries for path and all its descendants."""
        stale = [k for k in self._cache if k == path or path in k.parents]
        for k in stale:
            del self._cache[k]


@HinderCache
def get_hinder(path: Path) -> str | None:
    """
    Return the nearest path component that would block file or directory creation,
    or None if the path is unobstructed.

    A hinder is any existing non-directory: a regular file, a symlink to a file, or a
    broken symlink. Traverses upward until a hinder or a clean directory is found.
    """
    if str(path) == "/":
        return None
    if isbrokenlink(path):
        return str(path)
    if isdir(path) or islinkd(path):
        return None
    if not exists(path):
        return get_hinder(path.parent)
    return str(path)


# ── File operations ───────────────────────────────────────────────────────────


def remove_path(path: Path, *, verbose: bool = False, dry_run: bool = False) -> None:  # fmt: skip
    """Remove a file, directory, or (broken) symlink. Raises FileOperationError on failure."""
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
    """Return the next available backup path: <name>_1.bak, <name>_2.bak, ..."""
    n = 1
    while True:
        candidate = path.parent / f"{path.name}_{n}.bak"
        if not exists(candidate):
            return candidate
        n += 1


def make_backup(path: Path, *, verbose: bool = False, dry_run: bool = False) -> None:  # fmt: skip
    """Rename path to the next available backup name. Raises FileOperationError on failure."""
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


def _remove_hindrance(path: Path, *, verbose: bool = False, dry_run: bool = False) -> None:  # fmt: skip
    """Remove the nearest hinder blocking path and invalidate its cache entries."""
    if hinder := get_hinder(path):
        remove_path(Path(hinder), verbose=verbose, dry_run=dry_run)
        get_hinder.invalidate(Path(hinder))


# ── Conflict resolution ───────────────────────────────────────────────────────


def _clear_hinder(dst: Path, if_exists: str, *, verbose: bool = False, dry_run: bool = False) -> bool:  # fmt: skip
    """
    Resolve anything in the path to dst blocking its creation.

    Returns False if the caller should skip this destination entirely.
    The backed-up or removed path is a confirmed hinder, so the cache is invalidated.
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


def _clear_existing(dst: Path, if_exists: str, *, verbose: bool = False, dry_run: bool = False) -> bool:  # fmt: skip
    """
    Resolve dst itself already existing (e.g. a leftover directory).

    Returns False if the caller should skip this destination entirely.
    Directories return None from get_hinder, so they are not caught by _clear_hinder.
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


# ── Directory walk ────────────────────────────────────────────────────────────


def _walk_dir(src: Path, ignore: set[Path], *, verbose: bool = False) -> Generator[Path, None, None]:  # fmt: skip
    """Yield all files under src, skipping paths in ignore."""
    for root, dirs, files in src.walk():
        dirs[:] = [d for d in dirs if root / d not in ignore]
        for file in files:
            f = root / file
            if f in ignore:
                if verbose:
                    Logger.debug(f"Skipping (ignored): {f}")
                continue
            yield f


# ── Copy ──────────────────────────────────────────────────────────────────────


def _copy_file(
    src: Path,
    dest_dir: Path,
    src_root: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    """Copy a single file (or optionally a symlink) from src_root to dest_dir."""
    dst = dest_dir / src.relative_to(src_root)

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
    src_root: Path,
    ignore: set[Path],
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    """
    Copy a directory tree from src_root to dest_dir.

    An existing destination directory is entered rather than replaced; individual
    files within it handle their own if_exists policy.
    """
    dst = dest_dir / src.relative_to(src_root)

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
            src_root,
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
    src_root: str = "",
    ignore_globs: list[str] | None = None,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
    rebuild_symlinks: bool = False,
) -> None:
    """Copy files matching srcs globs from dotfiles_dir to dest_dir."""
    dotfiles_dir = dotfiles_dir.absolute()
    effective_root = (dotfiles_dir / src_root) if src_root else dotfiles_dir
    expanded_ignore = {match for glob in (ignore_globs or []) for match in effective_root.rglob(glob)}  # fmt: skip
    expanded_srcs = (match for glob in srcs for match in effective_root.glob(glob))  # fmt: skip

    for src in expanded_srcs:
        if src in expanded_ignore:
            if verbose:
                Logger.debug(f"Skipping (ignored): {src}")
            continue

        if isfile(src) or islink(src) or isbrokenlink(src):
            _copy_file(
                src,
                dest_dir,
                effective_root,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
                rebuild_symlinks=rebuild_symlinks,
            )
            continue

        _copy_dir(
            src,
            dest_dir,
            effective_root,
            expanded_ignore,
            verbose=verbose,
            dry_run=dry_run,
            if_exists=if_exists,
            rebuild_symlinks=rebuild_symlinks,
        )


# ── Link ──────────────────────────────────────────────────────────────────────


def _link_entry(
    src: Path,
    dest_dir: Path,
    src_root: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    if_exists: str = "ignore",
) -> None:
    """Create a symlink in dest_dir pointing to src in src_root."""
    dst = dest_dir / src.relative_to(src_root)

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
    src_root: str = "",
    ignore_globs: list[str] | None = None,
    recursive: bool = False,
    if_exists: str = "ignore",
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    """
    Symlink files matching srcs globs from dotfiles_dir into dest_dir.

    When recursive is False, directories are linked as a whole. When True,
    individual files within directories are linked instead.
    """
    dotfiles_dir = dotfiles_dir.absolute()
    effective_root = (dotfiles_dir / src_root) if src_root else dotfiles_dir
    expanded_ignore = {match for glob in (ignore_globs or []) for match in effective_root.rglob(glob)}  # fmt: skip
    expanded_srcs = [match for glob in srcs for match in effective_root.glob(glob)]  # fmt: skip

    for src in expanded_srcs:
        if src in expanded_ignore:
            if verbose:
                Logger.debug(f"Skipping (ignored): {src}")
            continue

        if not recursive or isfile(src) or islink(src) or isbrokenlink(src):
            _link_entry(
                src,
                dest_dir,
                effective_root,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
            )
            continue

        for f in _walk_dir(src, expanded_ignore, verbose=verbose):
            _link_entry(
                f,
                dest_dir,
                effective_root,
                verbose=verbose,
                dry_run=dry_run,
                if_exists=if_exists,
            )


# ── Command execution ─────────────────────────────────────────────────────────


def run_command(args: list[str], *, verbose: bool = False, dry_run: bool = False) -> None:  # fmt: skip
    """Run a subprocess command. Raises CommandError if the binary is missing or exits non-zero."""
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
        raise CommandError(f"Command failed: {cmd_string}\n{e.stderr.strip()}") from e

    if verbose:
        Logger.success(f"Command succeeded: {cmd_string}")


# ── Validation ────────────────────────────────────────────────────────────────


def _is_typed_dict(t: Any) -> bool:
    """Return True if t is a TypedDict class."""
    return (
        isinstance(t, type)
        and issubclass(t, dict)
        and hasattr(t, "__required_keys__")
        and hasattr(t, "__optional_keys__")
    )


def _is_union(hint: Any) -> bool:
    """Return True if hint is a union type (typing.Union or X | Y syntax)."""
    return typing.get_origin(hint) is Union or isinstance(hint, types.UnionType)


def _check_type(value: Any, hint: Any, path: str) -> list[str]:
    """
    Recursively validate value against a type annotation.

    Handles: NotRequired, Literal, list[T], Union/|, TypedDict, and plain types.
    Returns a list of error messages; empty means valid.
    """
    origin = typing.get_origin(hint)
    args = typing.get_args(hint)

    if origin is NotRequired:
        return _check_type(value, args[0], path)

    if origin is Literal:
        if value not in args:
            return [f"{path}: expected one of {list(args)!r}, got {value!r}"]
        return []

    if origin is list:
        if not isinstance(value, list):
            return [f"{path}: expected list, got {type(value).__name__!r}"]
        if not args:
            return []
        errs: list[str] = []
        for i, item in enumerate(value):
            errs.extend(_check_type(item, args[0], f"{path}[{i}]"))
        return errs

    if _is_union(hint):
        return _check_union(value, args, path)

    if _is_typed_dict(hint):
        return _validate_typed_dict(value, hint, path)

    if isinstance(hint, type):
        if not isinstance(value, hint):
            return [f"{path}: expected {hint.__name__}, got {type(value).__name__!r}"]
        return []

    return []


def _check_union(value: Any, union_args: tuple[Any, ...], path: str) -> list[str]:
    """
    Validate value against a union of types.

    For TypedDict unions (e.g. SetupStep), dispatches to the right TypedDict by
    matching the action key present in the dict. The key-to-TypedDict map is derived
    from the union members themselves, so adding a new step type requires no changes here.
    """
    td_members = [m for m in union_args if _is_typed_dict(m)]

    if td_members and isinstance(value, dict):
        key_map: dict[str, type] = {key: td for td in td_members for key in typing.get_type_hints(td)}  # fmt: skip
        matching = set(value.keys()) & key_map.keys()

        if not matching:
            return [f"{path}: expected one of {sorted(key_map)!r}, got keys {sorted(value.keys())!r}"]  # fmt: skip
        if len(matching) > 1:
            return [f"{path}: multiple action keys found: {sorted(matching)!r}"]

        return _validate_typed_dict(value, key_map[next(iter(matching))], path)

    # Non-TypedDict union: pass if value satisfies any member.
    for member in union_args:
        if not _check_type(value, member, path):
            return []
    return [f"{path}: value {value!r} doesn't match any expected type"]


def _validate_typed_dict(data: Any, td: type, path: str) -> list[str]:
    errs: list[str] = []

    if not isinstance(data, dict):
        errs.append(f"{path}: expected dict, got {type(data).__name__!r}")
        return errs

    hints = typing.get_type_hints(td, include_extras=True)
    required = {key for key, hint in hints.items() if typing.get_origin(hint) is not NotRequired}  # fmt: skip

    for key in required:
        if key not in data:
            errs.append(f"{path}: missing required key {key!r}")

    for key, val in data.items():
        if key not in hints:
            errs.append(f"{path}: unexpected key {key!r}")
            continue
        errs.extend(_check_type(val, hints[key], f"{path}.{key}"))

    return errs


def validate_spec(spec: Any) -> None:
    """Validate spec against the Spec TypedDict. Raises ConfigError listing all violations."""
    errors = _validate_typed_dict(spec, Spec, "SPECS")
    if errors:
        raise ConfigError("Invalid SPECS:\n" + "\n".join(f"  - {e}" for e in errors))  # fmt: skip


# ── Resume state ──────────────────────────────────────────────────────────────


def _make_state_path() -> Callable[[], Path]:
    """Return a closure that yields the state file path, computed once at module load."""
    path = (
        Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local" / "state"))
        / "dotfiles-bootstrap"
        / "state.json"
    )
    return lambda: path


_state_path: Callable[[], Path] = _make_state_path()


def _load_state() -> int:
    """Return the saved resume step index, or 0 if no state exists or it is unreadable."""
    try:
        data = json.loads(_state_path().read_text())
        return int(data["next_step"])
    except (FileNotFoundError, KeyError, ValueError, json.JSONDecodeError):
        return 0


def _save_state(next_step: int) -> None:
    """Persist the next step index to the state file. Logs a warning on failure."""
    path = _state_path()
    try:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps({"next_step": next_step}))
    except OSError as e:
        Logger.warn(f"Could not save resume state: {e}")


def _clear_state() -> None:
    """Delete the resume state file. Logs a warning on failure."""
    try:
        _state_path().unlink(missing_ok=True)
    except OSError as e:
        Logger.warn(f"Could not clear resume state: {e}")


# ── Dispatch ──────────────────────────────────────────────────────────────────


def dispatch(
    specs: Spec,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    from_start: bool = False,
    dotfiles_dir: str | None = None,
) -> None:
    """
    Validate and execute all setup steps defined in specs.

    Resumes from the last failed step unless from_start is True. Saves the failing
    step index on error so the next run can resume from it.
    """
    validate_spec(specs)

    _dotfiles_dir = (
        Path(dotfiles_dir).expanduser()
        if dotfiles_dir is not None
        else Path(
            os.path.expandvars(typing.cast(str, specs["DOTFILES_DIR"]))
        ).expanduser()
    )

    target_dir = Path(
        os.path.expandvars(typing.cast(str, specs["TARGET_DIR"]))
    ).expanduser()

    start_from = 0 if from_start else _load_state()

    if start_from > 0:
        label = f"steps 1-{start_from}" if start_from > 1 else "step 1"
        Logger.info(f"Resuming from step {start_from + 1}, skipping {label}.")

    for i, item in enumerate(specs["SETUP"]):
        if i < start_from:
            continue

        action, value = next(iter(item.items()))

        try:
            match action:
                case "CMD":
                    run_command(
                        typing.cast(list[str], value),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case "COPY":
                    v = typing.cast(CopySpec, value)
                    copy(
                        v["SRC_GLOBS"],
                        target_dir,
                        _dotfiles_dir,
                        src_root=v.get("SRC_ROOT", ""),
                        ignore_globs=v.get("IGNORE_GLOBS"),
                        if_exists=v.get("IF_EXISTS", "ignore"),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case "LINK":
                    v = typing.cast(LinkSpec, value)
                    link(
                        v["SRC_GLOBS"],
                        target_dir,
                        _dotfiles_dir,
                        src_root=v.get("SRC_ROOT", ""),
                        ignore_globs=v.get("IGNORE_GLOBS"),
                        recursive=v.get("RECURSIVE", False),
                        if_exists=v.get("IF_EXISTS", "ignore"),
                        verbose=verbose,
                        dry_run=dry_run,
                    )

                case _:
                    raise ConfigError(f"Step {i + 1}: unknown action {action!r}")

        except (DotfilesError, KeyboardInterrupt):
            _save_state(i)
            raise

    _clear_state()


# ── CLI ───────────────────────────────────────────────────────────────────────


class CliArgs(argparse.Namespace):
    """Typed namespace for parsed CLI arguments."""

    from_start: bool = False
    verbose: bool = False
    dry_run: bool = False
    dotfiles_dir: str | None = None


def main() -> int:
    """Parse CLI arguments and run the bootstrapper."""
    parser = argparse.ArgumentParser(description="Bootstrap a dotfiles repository.")
    parser.add_argument(
        "-1",
        "--from1",
        action="store_true",
        dest="from_start",
        help="Start from step 1, ignoring any saved resume state.",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Explain what is being done",
    )
    parser.add_argument(
        "-n",
        "--dry-run",
        action="store_true",
        dest="dry_run",
        help="Print what would be done without making any changes.",
    )
    parser.add_argument(
        "-D",
        "--dotfiles-dir",
        dest="dotfiles_dir",
        metavar="DIR",
        help="Override the DOTFILES_DIR from SPECS.",
    )
    args = parser.parse_args(namespace=CliArgs())

    try:
        dispatch(
            SPECS,
            verbose=args.verbose,
            dry_run=args.dry_run,
            from_start=args.from_start,
            dotfiles_dir=args.dotfiles_dir,
        )
    except DotfilesError as e:
        Logger.error(str(e))
        return 1
    except KeyboardInterrupt:
        Logger.error("Interrupted by user")
        return 130

    return 0


if __name__ == "__main__":
    sys.exit(main())


# pyright: basic
