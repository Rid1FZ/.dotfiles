# Fedora 44 + GNOME 50 Setup

Replicating the `hp450` NixOS configuration on Fedora 44 (GNOME 50).
Covers system-level configuration only — package installation is handled separately.

> **Package manager:** Fedora 44 uses `dnf5` natively. `dnf` still works as an alias.

---

## 1. Power Management

### 1.1 auto-cpufreq

**Why:** The default kernel governor doesn't distinguish between battery and charger
states. `auto-cpufreq` switches CPU governors and turbo boost policy based on power
source, extending battery life without sacrificing performance on AC.

**Important:** `auto-cpufreq` conflicts directly with `power-profiles-daemon` (both
try to manage CPU governors). The installer handles this automatically by masking
`power-profiles-daemon` — no need to mask it manually.

**Installation:** No official Fedora package or maintained COPR exists. Use the
upstream installer:

```bash
git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
```

When prompted, choose `i` to install the daemon. The installer will:
- Install the Python package
- Create and enable `auto-cpufreq.service`
- Automatically mask `power-profiles-daemon`

**Configuration** at `/etc/auto-cpufreq.conf`:

```ini
[battery]
governor = powersave
turbo = auto

[charger]
governor = performance
turbo = always
```

Restart the service after editing:

```bash
sudo systemctl restart auto-cpufreq
```

**Verify:**

```bash
sudo auto-cpufreq --stats
```

---

### 1.2 thermald

**Why:** Intel hardware throttles late — by the time the firmware reacts, performance
has already degraded. `thermald` monitors Intel thermal sensors and applies cooling
policies proactively before the hardware is forced to throttle.

```bash
sudo dnf5 install thermald
sudo systemctl enable --now thermald
```

**Note:** thermald and auto-cpufreq are explicitly designed to coexist. The
auto-cpufreq documentation recommends running both.

---

## 2. Memory Management

### 2.1 zram

**Why:** On a 4 GB machine, disk swap (HDD) is orders of magnitude slower than RAM.
zram creates a compressed swap device in RAM itself. With zstd compression you get
effectively ~2 GB of extra swap at memory speeds, keeping the system responsive instead
of grinding.

**Important:** Fedora 44 already ships with `zram-generator-defaults` installed and
active by default. Its default is 50% of RAM with an 8 GB cap, using zstd. You only
need to touch this if you want to customise it.

To override the defaults, create `/etc/systemd/zram-generator.conf`:

```ini
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
```

The default Fedora zram configuration may not have `swap-priority = 100` set. Adding
it explicitly ensures the kernel fills zram swap before ever touching disk swap.

**zstd module:** On some systems the zstd kernel module is not auto-loaded at boot for
zram. Ensure it loads reliably:

```bash
echo "zstd" | sudo tee /etc/modules-load.d/zstd.conf
```

**Apply without rebooting:**

```bash
sudo swapoff /dev/zram0
sudo zramctl --reset /dev/zram0
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

**Verify:**

```bash
zramctl
swapon --show
```

---

### 2.2 sysctl tuning

**Why:**
- `vm.swappiness = 100`: Tells the kernel to move anonymous memory to zram
  aggressively. This is correct with zram — you *want* to use the fast compressed swap
  rather than keep cold pages in RAM while evicting hot file cache.
- `vm.vfs_cache_pressure = 50`: Default is 100. Lowering it makes the kernel hold
  directory/inode cache longer, reducing HDD seeks on repeated filesystem operations.

Create `/etc/sysctl.d/99-custom.conf`:

```
vm.swappiness = 100
vm.vfs_cache_pressure = 50
```

Apply immediately:

```bash
sudo sysctl --system
```

---

### 2.3 earlyoom

**Why:** On a 4 GB machine the kernel OOM killer reacts too late — the system freezes
for seconds while memory thrashes before it acts. `earlyoom` runs in userspace,
monitoring free memory and swap continuously, and kills the heaviest process early to
keep the system interactive.

```bash
sudo dnf5 install earlyoom
```

Configure at `/etc/sysconfig/earlyoom`:

```
EARLYOOM_ARGS="-m 5 -s 5"
```

This kills when both free memory **and** free swap drop below 5%.

```bash
sudo systemctl enable --now earlyoom
```

---

## 3. CPU/IO Scheduling

### 3.1 ananicy-cpp

**Why:** When a browser, compiler, and LSP server compete for CPU/IO simultaneously,
the kernel assigns equal priority to all. `ananicy-cpp` applies a community-maintained
ruleset of `nice`/`ionice` priorities for known processes, reducing stutter during
interactive use.

**Not in official Fedora repos.** Install via the CachyOS COPR
(`bieszczaders/kernel-cachyos-addons`), which is the correct upstream source for
Fedora:

```bash
sudo dnf5 copr enable bieszczaders/kernel-cachyos-addons
sudo dnf5 install ananicy-cpp cachyos-ananicy-rules
sudo systemctl enable --now ananicy-cpp
```

`cachyos-ananicy-rules` provides the CachyOS-maintained ruleset for common
applications. The RPM spec auto-enables the service on install (`%posttrans`), but
explicitly enabling it is harmless.

**Note from the CachyOS README:** If you are also running a `sched-ext` scheduler,
`ananicy-cpp` can generally be used alongside it on modern versions. If you experience
stalls or instability, disable one as a troubleshooting step.

---

## 4. sudo

**Why these settings:**
- `pwfeedback`: Shows `*` while typing the password. Purely UX.
- `env_keep`: Preserves `EDITOR`, `PATH`, and `DISPLAY` across `sudo`. Without this,
  tools like `sudoedit`, GUI-adjacent commands, and editor integrations break.
- `passprompt`: Custom prompt. The `` glyph requires a Nerd Font in your terminal;
  it won't break anything if not installed but will show as a box.
- `NOPASSWD`: Mirrors `wheelNeedsPassword = false` from the NixOS config. Remove this
  line if you prefer to keep password prompts.

Create `/etc/sudoers.d/99-custom`:

```
Defaults pwfeedback
Defaults env_keep += "EDITOR PATH DISPLAY"
Defaults passprompt = "[sudo ]: "
%wheel  ALL=(ALL:ALL) NOPASSWD: ALL
```

**Always validate before saving:**

```bash
sudo visudo -cf /etc/sudoers.d/99-custom
sudo chmod 440 /etc/sudoers.d/99-custom
```

---

## 5. Shell

### 5.1 Install and configure zsh

```bash
sudo dnf5 install zsh zsh-autosuggestions zsh-syntax-highlighting
```

Fedora installs the plugin files to `/usr/share/` but does not source them
automatically. Create `/etc/zshrc.d/00-plugins.zsh` to enable them for every user:

```zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

### 5.2 Set zsh as default shell

```bash
sudo chsh -s $(which zsh) rid1
```

This takes effect on next login.

---

## 6. Session Environment Variables

**Why not `.zshenv` or `.profile`:** GNOME 50 on Wayland does not run a login shell at
session start. Files like `.zshenv`, `.profile`, and `/etc/profile` are not sourced
before GNOME starts. GUI applications launched from GNOME will not see variables set
there.

**The correct mechanism** is `environment.d`. Files placed in
`~/.config/environment.d/` are parsed by `systemd-environment-d-generator` and merged
into the systemd user instance environment before any user services or the desktop
session start. This makes them visible to all GUI applications, terminals, and
everything launched by GNOME.

**Variable expansion is supported.** The right-hand side of assignments can reference
previously-set variables using `$VAR` or `${VAR}` syntax. The `${VAR:+:$VAR}` form
(expand only if set) is also supported. No other shell syntax is available.

Create `~/.config/environment.d/99-session.conf`:

```ini
ANDROID_HOME=/home/rid1/Android/Sdk
JAVA_HOME=/usr/lib/jvm/java-17
RUST_SRC_PATH=/usr/lib/rustlib/src/rust/library
PATH=$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH
```

> `JAVA_HOME` path: verify the actual path after installing `java-17-openjdk-devel`
> with `dirname $(dirname $(readlink -f $(which javac)))`.

> `RUST_SRC_PATH`: if installed via rustup rather than the system package, use
> `$(rustc --print sysroot)/lib/rustlib/src/rust/library` in a shell to find the path
> and hardcode the result.

Changes take effect on next login. Verify after logging back in:

```bash
systemctl --user show-environment | grep PATH
```

---

## 7. Locale and Timezone

Fedora's installer sets these, but worth verifying they match the NixOS config.

```bash
sudo localectl set-locale LANG=en_US.UTF-8
sudo timedatectl set-timezone Asia/Dhaka
```

---

## 8. Fonts and Fontconfig

### 8.1 Install fonts

```bash
# Noto and Bengali (available in Fedora repos)
sudo dnf5 install google-noto-fonts-common google-noto-sans-cjk-fonts \
    google-noto-color-emoji-fonts lohit-bengali-fonts

# Adwaita fonts (ships with GNOME on Fedora 44)
# No separate install needed

# JetBrains Mono Nerd Font and Symbols Nerd Font
# Not in Fedora repos — download from https://www.nerdfonts.com/font-downloads
# Install to ~/.local/share/fonts/ and run:
fc-cache -f
```

### 8.2 fontconfig — Bengali font preference

**Why:** Without this, mixed Bengali/Latin text falls back to whatever fontconfig
picks, which is often inconsistent or incorrect for Bengali rendering.

The config file is `/etc/fonts/local.conf`. **Back up first** if it already exists on
your system, as it may contain Fedora-provided content.

```bash
[ -f /etc/fonts/local.conf ] && sudo cp /etc/fonts/local.conf /etc/fonts/local.conf.bak
```

Then write `/etc/fonts/local.conf`:

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <alias>
    <family>sans-serif</family>
    <prefer><family>Lohit Bengali</family></prefer>
  </alias>
  <alias>
    <family>serif</family>
    <prefer><family>Lohit Bengali</family></prefer>
  </alias>
</fontconfig>
```

```bash
sudo fc-cache -f
```

---

## 9. GNOME

### 9.1 GDM and Wayland

Fedora 44 enables GDM with Wayland by default. Nothing to configure. Verify if needed:

```bash
sudo systemctl status gdm
# Wayland is enabled unless WaylandEnable=false exists in /etc/gdm/custom.conf
```

### 9.2 Disabling LocalSearch (formerly Tracker)

**Why:** On a 4 GB machine with an HDD, LocalSearch's filesystem indexing competes
directly with everything else for both CPU and disk I/O.

**Service names changed in GNOME 46+ and remain the same in GNOME 50.** The old
`tracker-miner-fs-3` names no longer exist. The correct current names are:

```bash
systemctl --user mask \
    localsearch-3.service \
    localsearch-control-3.service \
    localsearch-writeback-3.service \
    tinysparql-xdg-portal-3.service
```

Run this as your normal user, not root.

**Important caveat:** Nautilus (GNOME Files) connects to LocalSearch at startup and
will log warnings when it can't reach it. This is harmless — Nautilus continues to
work normally. File search within Nautilus will fall back to a slower live search
rather than the index.

If the warnings bother you, GNOME Settings → Search allows you to limit which
directories are indexed rather than disabling it entirely, which is a softer
alternative.

### 9.3 Removing unwanted GNOME packages

Fedora can't exclude packages at install time like NixOS does.

```bash
sudo dnf5 remove gnome-maps gnome-weather gnome-contacts gnome-music \
    gnome-clocks gnome-connections simple-scan
```

**Warning:** Some of these are pulled back in by `@gnome-desktop` group updates. To
prevent this, mark them as explicitly removed:

```bash
sudo dnf5 mark remove gnome-maps gnome-weather gnome-contacts \
    gnome-music gnome-clocks gnome-connections simple-scan
```

### 9.4 Audio (PipeWire)

Fedora 44 ships PipeWire with WirePlumber and PulseAudio compatibility enabled by
default. This matches the NixOS setup exactly. Nothing to configure.

Verify all services are running:

```bash
systemctl --user status pipewire wireplumber pipewire-pulse
```

---

## 10. Networking

NetworkManager is enabled by default on Fedora. Nothing to do.

### OpenSSH

Not enabled by default on Fedora Workstation (unlike NixOS where it is declared).

```bash
sudo dnf5 install openssh-server
sudo systemctl enable --now sshd
```

---

## 11. Containers (Podman)

### Rootless Podman (subuid/subgid)

Fedora 40+ automatically allocates subuid/subgid ranges when creating a normal user.
Verify:

```bash
grep rid1 /etc/subuid /etc/subgid
```

Expected output (ranges may differ):

```
/etc/subuid:rid1:100000:65536
/etc/subgid:rid1:100000:65536
```

If missing:

```bash
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 rid1
```

### Podman socket (Docker compat)

```bash
systemctl --user enable --now podman.socket
```

For the `docker` CLI to work against Podman:

```bash
sudo ln -sf /run/user/$(id -u)/podman/podman.sock /var/run/docker.sock
```

---

## 12. Android development (udev rules)

The NixOS config adds `pkgs.android-tools` to the udev packages, which installs
Android USB device rules. On Fedora, install `android-tools` and then add your user
to the `plugdev` group:

```bash
sudo dnf5 install android-tools
sudo usermod -aG plugdev rid1
```

The package ships udev rules to `/etc/udev/rules.d/`. Re-log for group membership to
take effect.

---

## 13. nix-ld equivalent

The NixOS config enables `nix-ld` so that dynamically-linked binaries downloaded
outside the package manager can find a compatible loader. On Fedora this is not
necessary — the system linker and standard libraries are in standard FHS locations, so
arbitrary binaries work without any shim.

Nothing to do.

---

## Checklist

| # | Component | Command/File | Done |
|---|---|---|---|
| 1 | auto-cpufreq installed + daemon enabled | `auto-cpufreq-installer` | ☐ |
| 2 | auto-cpufreq configured | `/etc/auto-cpufreq.conf` | ☐ |
| 3 | power-profiles-daemon masked | done by installer | ☐ |
| 4 | thermald enabled | `systemctl enable --now thermald` | ☐ |
| 5 | zram customised (priority + zstd) | `/etc/systemd/zram-generator.conf` | ☐ |
| 6 | zstd module load ensured | `/etc/modules-load.d/zstd.conf` | ☐ |
| 7 | sysctl tuned | `/etc/sysctl.d/99-custom.conf` | ☐ |
| 8 | earlyoom installed + configured | `/etc/sysconfig/earlyoom` | ☐ |
| 9 | ananicy-cpp + rules (CachyOS COPR) | `bieszczaders/kernel-cachyos-addons` | ☐ |
| 10 | sudo configured | `/etc/sudoers.d/99-custom` | ☐ |
| 11 | zsh + plugins installed | `dnf5 install zsh zsh-autosuggestions ...` | ☐ |
| 12 | zsh plugins sourced system-wide | `/etc/zshrc.d/00-plugins.zsh` | ☐ |
| 13 | zsh set as default shell | `chsh -s $(which zsh) rid1` | ☐ |
| 14 | Session env vars configured | `~/.config/environment.d/99-session.conf` | ☐ |
| 15 | Locale set | `localectl set-locale LANG=en_US.UTF-8` | ☐ |
| 16 | Timezone set | `timedatectl set-timezone Asia/Dhaka` | ☐ |
| 17 | Fonts installed | `dnf5 install` + manual Nerd Fonts | ☐ |
| 18 | fontconfig (Bengali preference) | `/etc/fonts/local.conf` | ☐ |
| 19 | LocalSearch masked | `systemctl --user mask localsearch-3 ...` | ☐ |
| 20 | Unwanted GNOME packages removed | `dnf5 remove + mark remove` | ☐ |
| 21 | PipeWire verified | `systemctl --user status pipewire ...` | ☐ |
| 22 | OpenSSH enabled | `systemctl enable --now sshd` | ☐ |
| 23 | Podman subuid/subgid verified | `grep rid1 /etc/subuid` | ☐ |
| 24 | Podman socket enabled | `systemctl --user enable --now podman.socket` | ☐ |
| 25 | Android udev rules + plugdev group | `dnf5 install android-tools` | ☐ |
