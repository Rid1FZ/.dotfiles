# .dotfiles

## Theaming

Different applications uses different protocols for theaming. To set theme, use specific tools...

- GTK3: [lxappearance](https://github.com/lxde/lxappearance)
- GTK4: [Gnome Tweaks](https://gitlab.gnome.org/GNOME/gnome-tweaks)
- QT5: [qt5ct](https://github.com/desktop-app/qt5ct)
- QT6: [qt6ct](https://github.com/trialuser02/qt6ct)

It is **better** to use [Kvantum](https://github.com/tsujan/Kvantum) for QT theaming. But `qt5ct` doesn't detect Kvantum by default. For this, `kvantum-qt5` package needed to be installed.

## Desktop Portals

To use specific file picker, add the following to `$HOME/.config/xdg-desktop-portal/portals.conf`

```dosini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=gtk
```

QT5 applications might not use default file picker. To fix this, add the following to `$HOME/.config/qt5ct/qt5ct.conf`

```dosini
[Appearance]
standard_dialogs=xdgdesktopportal
```

NOTE: a reboot might be needed.

To make firefox use xdg-desktop-portal, go to `about:config` and change `widget.use-xdg-desktop-portal.file-picker` and `widget.use-xdg-desktop-portal.mime-handler` to `1` from `2`

To make QT5 applications follow theme, those should be run setting `QT_QPA_PLATFORMTHEME` to `qt5ct`. For example, to run VLC:

```bash
env QT_QPA_PLATFORMTHEME=qt5ct vlc
```

## Native Wayland Support

Electron applications, such as Chromium, Visual Studio Code, Discord supports Wayland natively, but uses XWayland. to make them use Wayland, pass these commandline flags

```
--enable-features=UseOzonePlatform --ozone-platform=wayland
```

For example, to run Chromium:

```bash
chromium-browser --enable-features=UseOzonePlatform --ozone-platform=wayland
```

## emacs

Get the latest stable tarball from [here](https://ftp.gnu.org/gnu/emacs).

Build it from source...

```bash
./configure --with-native-compilation=aot --without-ns --without-x --with-pgtk --prefix="$HOME/.local" --exec-prefix="$HOME/.local" --sysconfdir="$HOME/.config" --with-tree-sitter --without-compress-install --with-json --with-imagemagick
make -j $(nproc --all)
make install
```

Use `--aot` flag during Installation/Sync/Update of doom emacs to compile all packages to native binary...

```bash
doom install --aot
```

## Installation

Run the installer

```bash
python3 <(curl --location 'https://raw.githubusercontent.com/Rid1FZ/.dotfiles/master/bootstrap')

```

pass `--help` to installer for more options
