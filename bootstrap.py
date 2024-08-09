#!/usr/bin/env python3

import functools
import glob
import os
import os.path
import platform
import subprocess
import shlex
import shutil
from typing import Callable

# fmt: off
DOTFILES: str = os.environ.get("DOTFILES") or rf"{os.environ["HOME"]}/.dotfiles"

# these paths must be relative to dotfiles directory
PATHS_TO_COPY: tuple[str, ...] = (
    ".local/share/applications/*",
    ".local/share/backgrounds/*"
)

PATHS_TO_LINK: tuple[str, ...] = (
    ".zshrc",
    ".bashrc",
    ".bash_profile",
    ".profile.d",
    ".gitconfig",
    ".ipython/profile_default/*",
    ".local/bin/*",
    ".config/*"
)



PACKAGES: dict[str, tuple[str, ...]] = {
    # Required packages will be installed with optional dependencies
    'REQUIRED': (
        "qt6-qtwayland", "qt5-qtwayland", "kvantum", "polkit-kde", "hyprpicker", "tmux", "tar",
        "hyprland", "sddm", "ripgrep", "plocate", "eza", "fzf", "git", "nodejs", "zsh", "wlogout",
        "gh", "bat", "feh", "zathura", "zathura-pdf-poppler", "waybar", "symlinks", "trash-cli",
        "neovim", "fd-find", "exiftool", "zsh-autosuggestions", "zsh-syntax-highlighting", "unzip",
        "slurp", "grim", "python3-pip", "grimblast", "brave-browser", "kitty", "xdg-desktop-portal-gtk",
        "xdg-desktop-portal-hyprland", "zip",
    ),

    # Development and Theming tools will be installed without optional dependencies
    'DEVELOPMENT': (
        "freetype-devel", "cairo-devel", "pango-devel", "wayland-devel", "libxkbcommon-devel",
        "scdoc", "harfbuzz", "wayland-protocols-devel", "meson", "ninja", "make", "cmake",
        "clang", "clang-tools-extra",
    ),
    'THEMING': (
        "kvantum-qt5", "lxappearance", "gnome-tweaks", "qt6ct", "qt5ct",
    ),

    # Groups will be installed using 'dnf5 group install --with-optional ...'
    'GROUPS': (
        "multimedia", "fonts", "vlc",
    ),
    
    # Add commands to build and install any package. Every line will be considerd a command
    'BUILD_AND_INSTALL': (
        # rust tools
        r"""cd /tmp
        curl --proto '=https' --tlsv1.2 -sSf 'https://sh.rustup.rs' -o rustup.sh
        bash rustup.sh""",
        
        # tofi launcher
        r"""cd /tmp
        git clone 'https://github.com/philj56/tofi.git'
        cd tofi
        meson build
        ninja -C build install""",
    )
}

# Add commands to add third party repo. Every line will be considerd a command
REPOSITORIES: tuple[str, ...] = (
    # terra repo
    r"""sudo dnf install --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release --assumeyes""",

    # rpmfusion repos
    rf"""sudo dnf install 'https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-{platform.freedesktop_os_release()["VERSION_ID"]}.noarch.rpm' 'https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-{platform.freedesktop_os_release()["VERSION_ID"]}.noarch.rpm' --assumeyes""",

    # copr repo for hyprland tools
    r"""sudo dnf copr enable 'solopasha/hyprland' --assumeyes""",

    # brave browser repo
    r"""sudo dnf config-manager --add-repo 'https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo' --assumeyes
    sudo rpm --import 'https://brave-browser-rpm-release.s3.brave.com/brave-core.asc'""",
)
# fmt: on


def install_packages() -> None:
    global REPOSITORIES, PACKAGES

    if platform.freedesktop_os_release()["ID"] != "fedora":
        print("error: not fedora. skipping package installation...")
        return

    if not shutil.which("dnf5"):
        subprocess.call(["sudo", "dnf", "install", "dnf5", "--assumeyes"])

    subprocess.call(["sudo", "dnf5", "install", "dnf-plugins-core", "--assumeyes"])

    # enable repos
    for repo in REPOSITORIES:
        for command in repo.splitlines():
            subprocess.call(shlex.split(command))

    # required packages
    subprocess.call(["sudo", "dnf5", "install", *PACKAGES["REQUIRED"], "--assumeyes"])

    # development and theming tools
    subprocess.call(
        [
            "sudo",
            "dnf5",
            "install",
            "--setopt=install_weak_deps=False",
            "--assumeyes",
            *PACKAGES["DEVELOPMENT"],
            *PACKAGES["THEMING"],
        ]
    )

    # groups
    subprocess.call(
        [
            "sudo",
            "dnf5",
            "group",
            "install",
            "--with-optional",
            "--assumeyes",
            *PACKAGES["GROUPS"],
        ]
    )

    # extra packages
    for package in PACKAGES["BUILD_AND_INSTALL"]:
        for command in package.splitlines():
            subprocess.call(shlex.split(command))


def _setup_config(
    source: str, callback: Callable[[str, str], None], *, skip_if_available=True
) -> None:
    global DOTFILES

    target: str = os.path.join(os.environ["HOME"], source.removeprefix(DOTFILES + "/"))

    if os.path.exists(target) and skip_if_available:
        print(f"info: {target} exists. skipping...")
        return

    callback(source, target)


def copy_config(path: str, *, skip_if_available=True) -> None:
    global DOTFILES

    for source in glob.iglob(os.path.join(DOTFILES, path)):
        _setup_config(source, shutil.copy2, skip_if_available=skip_if_available)


def link_config(path: str, *, skip_if_available=True) -> None:
    global DOTFILES
    symlink: functools.partial = functools.partial(os.symlink, target_is_directory=True)

    for source in glob.iglob(os.path.join(DOTFILES, path)):
        _setup_config(source, symlink, skip_if_available=skip_if_available)


def main() -> None:
    global DOTFILES, PATHS_TO_COPY, PATHS_TO_LINK

    install_packages()

    os.makedirs(DOTFILES, exist_ok=True)
    subprocess.call(
        ["git", "clone", r"https://github.com/Rid1FZ/.dotfiles.git", DOTFILES]
    )

    for path in PATHS_TO_COPY:
        copy_config(path, skip_if_available=False)

    for path in PATHS_TO_LINK:
        link_config(path, skip_if_available=False)


if __name__ == "__main__":
    main()
