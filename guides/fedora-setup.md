# Fedora 45 Setup (GNOME 51 / KDE Plasma 6.8)

System-level configuration for Fedora Workstation (GNOME) and Fedora KDE Plasma
Desktop. Originally written to replicate the `hp450` NixOS configuration on
Fedora 44 + GNOME 50; revalidated in November 2026 against Fedora 45, GNOME 51
and KDE Plasma 6.8. Package installation is handled separately.

| Component | Target | Notes |
|---|---|---|
| Fedora | 45 (released 2026-11-03, EOL 2027-12-08) | Fedora 44 is still fine; items that differ are marked |
| GNOME | 51 | Wayland-only (X11 session removed in 50) |
| KDE Plasma | 6.8 | Wayland-only (X11 session removed in 6.8) |
| Kernel / systemd | 7.2 / 262 | |
| Package manager | `dnf5` | DNF 4 and `yum` no longer work as the system package manager |

Sections tagged **[GNOME]** or **[KDE]** apply to one desktop only; everything
else applies to both.

> **Reference machine:** Intel Core 3 100U, 8 GB DDR5-5600 (about 7.4 GiB
> usable), 512 GB NVMe (about 2 GB/s). Settings below are tuned for that:
> modest RAM, fast storage, a 15 W-class CPU.

---

## 0. Fedora 45 changes that affect this guide

1. **RPM refuses unverifiable packages.** `%_pkgverify_level` is now `all`, so
   `rpm -i some.rpm` fails if the signing key is not imported (it only warned on
   Fedora 44). Prefer `sudo dnf install ./some.rpm` for a vendor release RPM you
   trust (it installs the repo and key), or `rpm --nosignature` for a single
   package. Check with `rpm --eval %_pkgverify_level`.
2. **Repo files moved to `/usr`.** Fedora's own `.repo` files are in
   `/usr/share/dnf5/repos.d/` and keys in `/usr/share/pki/rpm-gpg/`;
   `/etc/yum.repos.d/` ships empty (third-party repos still go there). Do not
   edit the `/usr` copies. Toggle repos with `sudo dnf5 config-manager setopt
   <repo>.enabled=0`, which writes a drop-in under `/etc/dnf/repos.override.d/`.
3. **Virtual consoles use kmscon.** `setfont`/`loadkeys` no longer affect the
   TTY; layout comes from `localectl`, fonts from `/etc/kmscon/kmscon.conf`
   (copy `kmscon.conf.example`).
4. **ptrace is restricted** (`kernel.yama.ptrace_scope = 1`). Debuggers that
   attach to a running PID (gdb, lldb, strace -p, nvim-dap attach) fail with
   `Operation not permitted` until `yama-ptrace-enable` is installed. See §13.
5. **Podman 6**: slirp4netns, cgroups v1 and BoltDB are gone. See §11.
6. **DNF5 no longer switches a package's vendor** during upgrades/dependency
   resolution by default. Relevant if you mix RPM Fusion / COPR builds.
7. **KDE edition uses Plasma Login Manager (PLM)** on fresh installs since
   Fedora 44. Systems upgraded from older releases may still run SDDM.

---

## 1. Power Management

### 1.1 auto-cpufreq

**Why:** The default kernel governor does not distinguish battery from charger.
`auto-cpufreq` switches governor and turbo policy based on power source.

**Conflicts:** `auto-cpufreq` conflicts with every other CPU/power-profile
daemon. On Fedora the default one since Fedora 41 is **TuneD (`tuned` +
`tuned-ppd`)**, not `power-profiles-daemon`. Upstream's installer disables the
active one for you. Check what is running first:

```bash
systemctl is-active tuned tuned-ppd power-profiles-daemon auto-cpufreq
```

**Trade-off:** `tuned-ppd` and `power-profiles-daemon` provide the D-Bus API
behind the **GNOME Quick Settings power-mode toggle** and the **Plasma battery
applet power-profile switcher**. With auto-cpufreq in charge, those controls
stop doing anything. That is expected, not a bug.

**Installation (auto-cpufreq):** no maintained Fedora package; use the upstream
installer, which upstream recommends over distro packages:

```bash
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
```

Choose `i` (install daemon). It installs the service and disables the
conflicting daemon (TuneD on Fedora). Verify the conflicting units afterwards
with the `systemctl is-active` command above.

**Configuration** at `/etc/auto-cpufreq.conf`:

```ini
[battery]
governor = powersave
turbo = auto

[charger]
governor = performance
turbo = always
```

```bash
sudo systemctl restart auto-cpufreq
sudo auto-cpufreq --stats
```

> `turbo = always` on a thin 15 W-class laptop will hit thermal limits sooner
> and can lower sustained performance; pair it with thermald (§1.2) and watch
> temperatures before keeping it.

---

### 1.2 thermald

**Why:** Intel hardware throttles late. `thermald` applies cooling policy
proactively.

```bash
sudo dnf5 install thermald
sudo systemctl enable --now thermald
```

thermald and auto-cpufreq are documented to coexist (upstream recommends both).

---

## 2. Memory Management

### 2.1 zram

**Why:** with 8 GB of RAM, zram (compressed swap in RAM, zstd) gives swap at
memory speed and keeps the system responsive under load.

Fedora ships `zram-generator-defaults`. The shipped default can change between
releases, so read it instead of trusting this guide:

```bash
cat /usr/lib/systemd/zram-generator.conf
zramctl
```

To override, create `/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = min(ram, 8192)
compression-algorithm = zstd
swap-priority = 100
```

(`zram-size` is in MiB and accepts expressions; this gives up to 8 GiB.)
`swap-priority = 100` makes the kernel fill zram before any disk swap.

**Apply without rebooting:**

```bash
sudo swapoff /dev/zram0
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0.service
zramctl && swapon --show
```

---

### 2.2 sysctl tuning

With zram, swapping is cheap, so the kernel should prefer compressing cold
anonymous pages over evicting hot file cache. These are the commonly used zram
values (also the ArchWiki/Pop!_OS recommendations):

| Setting | Value | Why |
|---|---|---|
| `vm.swappiness` | 180 | Range is 0-200; high values favour zram over dropping file cache |
| `vm.page-cluster` | 0 | zram has no seek cost; read pages one at a time, not in read-ahead clusters |
| `vm.watermark_boost_factor` | 0 | Disable watermark boosting (causes needless reclaim bursts) |
| `vm.watermark_scale_factor` | 125 | Start background reclaim earlier |

Create `/etc/sysctl.d/99-zram.conf`:

```
vm.swappiness = 180
vm.page-cluster = 0
vm.watermark_boost_factor = 0
vm.watermark_scale_factor = 125
```

```bash
sudo sysctl --system
```

---

### 2.3 Out-of-memory handling

Fedora Workstation and KDE use **systemd-oomd** by default. It kills by cgroup
memory pressure.

```bash
systemctl status systemd-oomd
oomctl
```

Do not also install `earlyoom`; two userspace OOM killers fight each other.

---

## 3. CPU/IO Scheduling

### 3.1 ananicy-cpp

**Why:** When a browser, compiler and LSP server compete, the kernel treats
them equally. `ananicy-cpp` applies a community ruleset of `nice`/`ionice`
priorities by process name.

Not in the official repos; use the CachyOS COPR:

```bash
sudo dnf5 copr enable bieszczaders/kernel-cachyos-addons
sudo dnf5 install ananicy-cpp cachyos-ananicy-rules
sudo systemctl enable --now ananicy-cpp
```

If `copr enable` or the install reports no build for `fedora-45`, the COPR has
not caught up yet; wait or stay on 44 for this package. If you run a `sched-ext`
scheduler and see stalls, disable one of the two as a troubleshooting step.

---

## 4. sudo

**Why these settings:**
- `pwfeedback`: show `*` while typing the password (UX only).
- `env_keep += "EDITOR"`: keeps your editor for `sudoedit`/`visudo`.
- `passprompt`: custom prompt. The glyph needs a Nerd Font; otherwise it shows
  as a box.
- `NOPASSWD`: mirrors `wheelNeedsPassword = false` from the NixOS config.

> **Security trade-off:** with `NOPASSWD`, any process running as your user
> (a malicious npm/pip package, a compromised editor plugin) can become root
> silently. Remove that line if you value the prompt.

Changes from the old revision: `DISPLAY` is dropped (both desktops are
Wayland-only, so it is meaningless; do not run GUI apps as root, use polkit
or `sudoedit`), and `PATH` is dropped because Fedora's default sudoers sets
`secure_path`, which overrides it.

Create `/etc/sudoers.d/99-custom`:

```
Defaults pwfeedback
Defaults env_keep += "EDITOR"
Defaults passprompt = "[sudo ]: "
%wheel  ALL=(ALL:ALL) NOPASSWD: ALL
```

```bash
sudo visudo -cf /etc/sudoers.d/99-custom
sudo chmod 440 /etc/sudoers.d/99-custom
```

---

## 5. Shell

### 5.1 Install zsh

```bash
sudo dnf5 install zsh zsh-autosuggestions zsh-syntax-highlighting
```

Fedora installs the plugins under `/usr/share/` but does not source them.
Preferred: source them per user from the dotfiles (`zprofile.d/plugins.zsh`
already loads anything under `~/.local/share/zsh/plugins` or `~/.zsh/plugins`;
symlink or copy the system plugins there).

A system-wide alternative is `/etc/zshrc.d/00-plugins.zsh`, but that only works
if Fedora's `/etc/zshrc` loops over that directory. Check first:

```bash
grep -n zshrc.d /etc/zshrc
```

### 5.2 Default shell

```bash
sudo chsh -s "$(command -v zsh)" "$USER"
```

Takes effect on next login.

---

## 6. Session Environment Variables

**Why not `.zshenv` / `.profile`:** Neither GNOME nor Plasma runs a login shell
at session start on Wayland, so those files are not read before the desktop
starts. GUI apps launched from the menu will not see variables set there.

### Mechanism 1 (both desktops): `environment.d`

Files in `~/.config/environment.d/*.conf` are parsed by
`systemd-environment-d-generator` and merged into the systemd user manager's
environment, which GNOME and Plasma both inherit.

Supported syntax is only `KEY=value` with `$VAR` / `${VAR}` / `${VAR:+...}`
expansion. No other shell syntax.

### Mechanism 2 **[KDE]**: `plasma-workspace/env`

Plasma sources `~/.config/plasma-workspace/env/*.sh` (shell scripts; variables
must be exported) during startup, on Wayland too. This is the documented KDE
mechanism and it can run commands, unlike `environment.d`.

**Known caveat:** `startplasma` runs these scripts *without* the systemd
environment and then syncs the result back into systemd, which can overwrite
PATH-style variables set via `environment.d`
(KDE bugs [491579](https://bugs.kde.org/show_bug.cgi?id=491579) and
[505529](https://bugs.kde.org/show_bug.cgi?id=505529), both still open when
checked). The repo's `home/.config/plasma-workspace/env/load_env.sh` works
around this by sourcing `~/.config/environment.d/*.conf` and then
`profile.d/env-vars.sh` itself, so both mechanisms yield the same environment.
Because it sources the `.conf` files as shell, keep them compatible with both
parsers (plain `KEY=value`, no spaces around `=`).

### Layout used by the dotfiles

- `~/.config/environment.d/envvars.conf`: only bootstrap variables (`XDG_*`,
  `GTK_USE_PORTAL`, base `PATH`).
- `~/.config/profile.d/env-vars.sh`: the rest (`JAVA_HOME`, `ANDROID_HOME`,
  `CARGO_HOME`, extended `PATH`, ...). Do not duplicate them here.

> `JAVA_HOME`: the repo points at `/usr/lib/jvm/java-openjdk` (the
> alternatives symlink). If you need a specific JDK, check
> `dirname "$(dirname "$(readlink -f "$(command -v javac)")")"`.
> `RUST_SRC_PATH` with rustup: `$(rustc --print sysroot)/lib/rustlib/src/rust/library`.

Changes apply on next login. Verify:

```bash
systemctl --user show-environment | grep -E '^(PATH|XDG_CONFIG_HOME)='
```

---

## 7. Locale and Timezone

```bash
sudo localectl set-locale LANG=en_US.UTF-8
sudo timedatectl set-timezone Asia/Dhaka
```

(`localectl set-x11-keymap` also sets the keyboard layout used by the kmscon
console on Fedora 45.)

---

## 8. Fonts and Fontconfig

### 8.1 Install fonts

Package names drift between releases; confirm before installing:

```bash
dnf5 search noto-fonts emoji bengali
```

Typical set:

```bash
sudo dnf5 install google-noto-sans-cjk-fonts google-noto-color-emoji-fonts
```

Nerd Fonts (JetBrainsMono, Ubuntu, Symbols) are not in the Fedora repos:
download from <https://www.nerdfonts.com/font-downloads>, unpack into
`~/.local/share/fonts/`, then `fc-cache -f`. Li Ador Noirrit (Bengali) goes the
same way.

### 8.2 Fontconfig

fontconfig is shared by GTK, Qt and everything else, so one config covers
GNOME and KDE apps. The old revision wrote a system-wide
`/etc/fonts/local.conf` preferring Lohit Bengali; that has been replaced by the
per-user file in the repo, `home/.config/fontconfig/fonts.conf`:

- sans-serif / serif: Ubuntu Nerd Font, then Li Ador Noirrit (Bengali), then
  Noto Color Emoji
- monospace: JetBrainsMono Nerd Font, Symbols Nerd Font, Li Ador Noirrit,
  Noto Color Emoji
- slight hinting, antialiasing on

Verify resolution:

```bash
fc-match sans-serif
fc-match monospace
fc-match "sans-serif:lang=bn"
```

Per-desktop UI font selection is separate: **[GNOME]** Settings/Tweaks (or
dconf `org/gnome/desktop/interface`), **[KDE]** System Settings → Text & Fonts.

---

## 9. Desktop

### 9.1 Display manager

- **[GNOME]** GDM, Wayland. Nothing to configure. A `WaylandEnable=false` line
  in `/etc/gdm/custom.conf` no longer gives an X11 session (removed in GNOME 50).
- **[KDE]** Fresh Fedora 44+ KDE installs use **Plasma Login Manager**
  (`plasmalogin.service`); older/upgraded systems may still use SDDM.

```bash
systemctl is-enabled plasmalogin sddm 2>/dev/null
```

To migrate an upgraded system (from the Fedora change page workflow):

```bash
sudo dnf5 install plasma-login-manager
sudo systemctl disable sddm && sudo systemctl enable plasmalogin
sudo reboot
```

PLM does not support SDDM theme packages; its appearance is configured in
System Settings.

### 9.2 Desktop search indexer

**Why:** background indexing competes for CPU during builds and on battery.

**[GNOME] LocalSearch** (formerly Tracker). Service names are unchanged in
GNOME 51 (LocalSearch 3.12 still uses the `-3` units):

```bash
systemctl --user mask \
    localsearch-3.service \
    localsearch-control-3.service \
    localsearch-writeback-3.service \
    tinysparql-xdg-portal-3.service
```

Run as your normal user. Verify unit names on your system first:
`systemctl --user list-unit-files 'localsearch*' 'tinysparql*'`.
Nautilus logs harmless warnings when it cannot reach LocalSearch and falls back
to slower live search. A softer option is limiting indexed directories in
Settings → Search. The repo's `gnome.dconf` already carries an
`ignored-directories` list for the tracker miner.

**[KDE] Baloo** (`balooctl6` on Plasma 6):

```bash
balooctl6 status          # see current state
balooctl6 disable         # stop indexing
balooctl6 purge           # optional: delete the existing index
```

Or System Settings → Search → File Search. KRunner and Dolphin search keep
working (Dolphin falls back to non-indexed search).

### 9.3 Removing unwanted packages

Fedora cannot exclude packages at install time like NixOS.

**[GNOME]**

```bash
sudo dnf5 remove gnome-maps gnome-weather gnome-contacts gnome-music \
    gnome-clocks gnome-connections simple-scan
```

**[KDE]** Preview first; KDE package names are many and some are shared
dependencies:

```bash
sudo dnf5 remove --assumeno kdeconnectd plasma-welcome
```

**Keeping them removed.** The previous revision used `dnf5 mark remove`; that
subcommand does not exist in DNF5 (`mark` supports only `user`, `dependency`,
`weak`, `group`). Removed packages can return as weak dependencies or via a
group upgrade. To stop that, exclude them in a libdnf5 drop-in,
`/etc/dnf/libdnf5.conf.d/50-excludes.conf`:

```ini
[main]
excludepkgs=gnome-maps,gnome-weather,gnome-contacts,gnome-music,gnome-clocks,gnome-connections,simple-scan
```

(Edit the list for your desktop. Excluded packages are invisible to every dnf
operation, so remove the line if you ever want one back.)

### 9.4 Keyring / secrets **[GNOME]**

Fedora 45 + GNOME 51 moves the Secret Service provider from GNOME Keyring to
**oo7** (`oo7-daemon`, `pam_oo7`), migrating existing keyrings. Both daemons
stay installed. Check which one owns the bus name after login:

```bash
busctl --user status org.freedesktop.secrets
```

### 9.5 Audio (PipeWire)

Both desktops use PipeWire + WirePlumber with PulseAudio compatibility by
default. Nothing to configure.

```bash
systemctl --user status pipewire wireplumber pipewire-pulse
```

### 9.6 Wayland-only

Neither desktop offers an X11 session anymore. X11 apps run through XWayland.

---

## 10. Networking

NetworkManager is enabled by default. OpenSSH (Fedora 45 ships 10.5) is not
installed on the desktop editions:

```bash
sudo dnf5 install openssh-server
sudo systemctl enable --now sshd
```

**[GNOME]** GNOME 51's Settings → System → Remote Login can enable
socket-activated SSH instead of a permanently running daemon.

---

## 11. Containers (Podman 6)

Fedora 45 ships Podman 6.1.

### Breaking changes

- `slirp4netns` is removed; rootless networking is **pasta**. Any
  `--network slirp4netns` in scripts or Quadlet files must change to
  `--network pasta` (then run `podman system migrate` for existing containers).
- BoltDB cannot be read anymore (SQLite only), cgroups v1 and the netavark
  iptables backend are gone. Before upgrading from 44, check:

```bash
podman info --format '{{.Host.DatabaseBackend}}'   # must say sqlite
```

### Rootless (subuid/subgid)

```bash
grep "$USER" /etc/subuid /etc/subgid
```

If missing:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 "$USER"
```

### Docker compatibility

The previous revision ran `ln -sf /run/user/$UID/podman/podman.sock
/var/run/docker.sock`. That is wrong twice: `/var/run` is `/run` (a tmpfs, so
the link vanishes on reboot) and `/var/run/docker.sock` is where *root*
clients look. Instead:

```bash
systemctl --user enable --now podman.socket
sudo dnf5 install podman-docker          # `docker` CLI shim + man pages
```

and point the client at the rootless socket by adding to
`~/.config/environment.d/envvars.conf` (or `profile.d/env-vars.sh`):

```
DOCKER_HOST=unix://${XDG_RUNTIME_DIR}/podman/podman.sock
```

(`XDG_RUNTIME_DIR` is not guaranteed to be set when `environment.d` is parsed;
if `echo $DOCKER_HOST` is wrong after login, set it in `profile.d/env-vars.sh`
as `unix:///run/user/$(id -u)/podman/podman.sock` instead.)

---

## 12. Android development (udev)

The NixOS config added `android-tools` to the udev packages. On Fedora:

```bash
sudo dnf5 install android-tools
```

Fedora has no `plugdev` group (that is a Debian convention); the earlier
`usermod -aG plugdev` step was therefore wrong. Device access is normally
granted to the active local user through logind's `uaccess` tag. Verify with a
phone attached and USB debugging on:

```bash
getent group plugdev || echo "no plugdev group (expected)"
adb devices
```

If `adb devices` shows `no permissions`, inspect the device node
(`ls -l /dev/bus/usb/*/*`) and the installed rules
(`rpm -ql android-tools | grep rules`) before adding groups.

---

## 13. Debuggers and ptrace (Fedora 45)

Fedora 45 sets `kernel.yama.ptrace_scope = 1`: unprivileged processes can trace
only their own children. Attaching to a running process (`gdb -p`,
`strace -p`, `lldb`, nvim-dap attach, `py-spy`) fails with
`Operation not permitted`. Installing strace pulls in the fix only as a weak
dependency; gdb does not. Install it explicitly:

```bash
sudo dnf5 install yama-ptrace-enable
sysctl kernel.yama.ptrace_scope    # expect 0
```

This lowers a hardening default; it is the same behaviour Fedora 44 had.

---

## 14. nix-ld equivalent

On Fedora, binaries downloaded outside the package manager work because the
loader and libraries are in FHS locations. Nothing to do.

---

## Checklist

| # | Component | Command/File | Done |
|---|---|---|---|
| 1 | Power daemon decision (auto-cpufreq vs tuned-ppd/PPD) | `systemctl is-active tuned tuned-ppd power-profiles-daemon` | ☐ |
| 2 | auto-cpufreq installed + configured (if chosen) | `/etc/auto-cpufreq.conf` | ☐ |
| 3 | thermald enabled | `systemctl enable --now thermald` | ☐ |
| 4 | zram customised | `/etc/systemd/zram-generator.conf` | ☐ |
| 5 | sysctl tuned | `/etc/sysctl.d/99-zram.conf` | ☐ |
| 6 | systemd-oomd active (no earlyoom) | `systemctl status systemd-oomd` | ☐ |
| 7 | ananicy-cpp + rules (CachyOS COPR) | `bieszczaders/kernel-cachyos-addons` | ☐ |
| 8 | sudo configured | `/etc/sudoers.d/99-custom` | ☐ |
| 9 | zsh + plugins sourced | `dnf5 install zsh ...`, `plugins.zsh` | ☐ |
| 10 | zsh default shell | `chsh -s "$(command -v zsh)" "$USER"` | ☐ |
| 11 | Session env vars | `environment.d/envvars.conf`, `profile.d/env-vars.sh` | ☐ |
| 12 | [KDE] Plasma env loader | `plasma-workspace/env/load_env.sh` | ☐ |
| 13 | Locale + timezone | `localectl`, `timedatectl` | ☐ |
| 14 | Fonts + fontconfig | `~/.config/fontconfig/fonts.conf` | ☐ |
| 15 | [KDE] Login manager checked | `plasmalogin` vs `sddm` | ☐ |
| 16 | Indexer disabled | [GNOME] mask `localsearch-3*` / [KDE] `balooctl6 disable` | ☐ |
| 17 | Unwanted packages removed + excluded | `dnf5 remove`, `libdnf5.conf.d/50-excludes.conf` | ☐ |
| 18 | PipeWire verified | `systemctl --user status pipewire ...` | ☐ |
| 19 | OpenSSH enabled | `systemctl enable --now sshd` | ☐ |
| 20 | Podman subuid/subgid + no slirp4netns/BoltDB | `grep $USER /etc/subuid`, `podman info` | ☐ |
| 21 | Podman socket + `DOCKER_HOST` | `systemctl --user enable --now podman.socket` | ☐ |
| 22 | android-tools, device visible | `adb devices` | ☐ |
| 23 | Debugger ptrace enabled | `dnf5 install yama-ptrace-enable` | ☐ |
