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
            "LINK": {
                "SRC_GLOBS": [".config/nvim", ".config/tmux"],
                "RECURSIVE": False,
                "FORCE": True,
            }
        },
        {
            "COPY": {
                "SRC_GLOBS": [".local/share/applications/*"],
                "IGNORE_GLOBS": [".local/share/applications/nvim.desktop"],
                "FORCE": True,
            }
        },
        {
            "LINK": {
                "SRC_GLOBS": [".local/bin/*"],
                "IGNORE_GLOBS": [],
                "RECURSIVE": False,
                "FORCE": False,
            }
        },
        {"CMD": ["systemctl", "--user", "enable", "--now", "syncthing"]},
    ],
}


class SpecError(Exception):
    pass


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
    force: bool = False,
    rebuild_symlinks: bool = False,
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        if not force:
            Logger.error(f"Skipping {dst}: blocked by {hinder}")
            return

        _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)

    if exists(dst) and not force:
        if verbose:
            Logger.debug(f"Skipping (already exists): {dst}")
        return

    if dry_run:
        Logger.info(f"[dry-run] Would copy: {src} -> {dst}")
        return

    remove_path(dst, verbose=verbose, dry_run=dry_run)
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
    force: bool = False,
    rebuild_symlinks: bool = False,
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        if not force:
            Logger.error(f"Skipping {dst}: blocked by {hinder}")
            return

        _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)

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
            force=force,
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
    force: bool = False,
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
                force=force,
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
            force=force,
            rebuild_symlinks=rebuild_symlinks,
        )


def _link_entry(
    src: Path,
    dest_dir: Path,
    dotfiles_dir: Path,
    *,
    verbose: bool = False,
    dry_run: bool = False,
    force: bool = False,
) -> None:
    dst = dest_dir / src.relative_to(dotfiles_dir)

    if hinder := get_hinder(dst):
        if not force:
            Logger.error(f"Skipping {dst}: blocked by {hinder}")
            return

        _remove_hindrance(dst, verbose=verbose, dry_run=dry_run)

    if exists(dst) and not force:
        if verbose:
            Logger.debug(f"Skipping (already exists): {dst}")
        return

    if dry_run:
        Logger.info(f"[dry-run] Would link: {dst} -> {src.absolute()}")
        return

    remove_path(dst, verbose=verbose)
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
    force: bool = False,
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
                force=force,
            )
            continue

        for f in _walk_dir(src, expanded_ignore_globs, verbose=verbose):
            _link_entry(
                f,
                dest_dir,
                dotfiles_dir,
                verbose=verbose,
                dry_run=dry_run,
                force=force,
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


def _validate_str_list(
    value: object, errors: list[str], prefix: str, *, allow_empty: bool
) -> None:
    if not isinstance(value, list):
        errors.append(f"{prefix}: must be a list of strings")
        return
    if not allow_empty and not value:
        errors.append(f"{prefix}: must not be empty")
        return
    for i, item in enumerate(value):
        if not isinstance(item, str):
            errors.append(f"{prefix}[{i}]: must be a string, got {type(item).__name__}")


def _validate_cmd(value: object, errors: list[str], prefix: str) -> None:
    _validate_str_list(value, errors, prefix, allow_empty=False)


def _validate_copy(value: object, errors: list[str], prefix: str) -> None:
    if not isinstance(value, dict):
        errors.append(f"{prefix}: must be a dict")
        return

    valid_keys = {"SRC_GLOBS", "IGNORE_GLOBS", "FORCE"}
    for key in value:
        if key not in valid_keys:
            errors.append(f"{prefix}: unknown key '{key}'")

    if "SRC_GLOBS" not in value:
        errors.append(f"{prefix}: missing required key 'SRC_GLOBS'")
    else:
        _validate_str_list(
            value["SRC_GLOBS"], errors, f"{prefix}.SRC_GLOBS", allow_empty=False
        )

    if "IGNORE_GLOBS" in value:
        _validate_str_list(
            value["IGNORE_GLOBS"], errors, f"{prefix}.IGNORE_GLOBS", allow_empty=True
        )

    if "FORCE" in value and not isinstance(value["FORCE"], bool):
        errors.append(f"{prefix}.FORCE: must be a bool")


def _validate_link(value: object, errors: list[str], prefix: str) -> None:
    if not isinstance(value, dict):
        errors.append(f"{prefix}: must be a dict")
        return

    valid_keys = {"SRC_GLOBS", "IGNORE_GLOBS", "RECURSIVE", "FORCE"}
    for key in value:
        if key not in valid_keys:
            errors.append(f"{prefix}: unknown key '{key}'")

    if "SRC_GLOBS" not in value:
        errors.append(f"{prefix}: missing required key 'SRC_GLOBS'")
    else:
        _validate_str_list(
            value["SRC_GLOBS"], errors, f"{prefix}.SRC_GLOBS", allow_empty=False
        )

    if "IGNORE_GLOBS" in value:
        _validate_str_list(
            value["IGNORE_GLOBS"], errors, f"{prefix}.IGNORE_GLOBS", allow_empty=True
        )

    if "RECURSIVE" in value and not isinstance(value["RECURSIVE"], bool):
        errors.append(f"{prefix}.RECURSIVE: must be a bool")

    if "FORCE" in value and not isinstance(value["FORCE"], bool):
        errors.append(f"{prefix}.FORCE: must be a bool")


def _validate_setup(setup: object, errors: list[str]) -> None:
    if not isinstance(setup, list):
        errors.append("'SETUP': must be a list")
        return

    valid_actions = {"CMD", "COPY", "LINK"}
    validators = {"CMD": _validate_cmd, "COPY": _validate_copy, "LINK": _validate_link}

    for i, item in enumerate(setup):
        prefix = f"SETUP[{i}]"

        if not isinstance(item, dict):
            errors.append(f"{prefix}: must be a dict")
            continue

        if len(item) != 1:
            errors.append(
                f"{prefix}: must have exactly one key, got {list(item.keys())}"
            )
            continue

        action, value = next(iter(item.items()))

        if action not in valid_actions:
            errors.append(
                f"{prefix}: unknown action '{action}', valid: {valid_actions}"
            )
            continue

        validators[action](value, errors, f"{prefix}.{action}")


def validate_spec(specs: object) -> None:
    errors = []

    if not isinstance(specs, dict):
        Logger.error("spec must be a dict")
        raise SpecError("spec must be a dict")

    valid_top_level = {"DOTFILES_DIR", "DOTFILES_REMOTE", "TARGET_DIR", "SETUP"}

    for key in specs:
        if key not in valid_top_level:
            errors.append(f"unknown top-level key: '{key}'")

    for key in valid_top_level:
        if key not in specs:
            errors.append(f"missing required key: '{key}'")

    for key in ("DOTFILES_DIR", "DOTFILES_REMOTE", "TARGET_DIR"):
        if key in specs and not isinstance(specs[key], str):
            errors.append(f"'{key}': must be a string")

    if "SETUP" in specs:
        _validate_setup(specs["SETUP"], errors)

    if errors:
        for error in errors:
            Logger.error(error)
        raise SpecError(f"invalid spec: {len(errors)} error(s) found")


def dispatch(
    specs: dict,
    *,
    verbose: bool = False,
    dry_run: bool = False,
) -> None:
    validate_spec(specs)

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
                    force=value.get("FORCE", False),
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
                    force=value.get("FORCE", False),
                    verbose=verbose,
                    dry_run=dry_run,
                )


def main() -> int:
    return 0


if __name__ == "__main__":
    sys.exit(main())
