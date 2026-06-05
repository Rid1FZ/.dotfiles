# Fedora 44 + GNOME 50 Memory & Performance Optimization

Notes on reducing unnecessary RAM usage and background activity on Fedora 44
Workstation.

> Tested against: Fedora 44, GNOME 50, Wayland-only session (X11 is no longer
> offered). Commands use `dnf5`, the native package manager since Fedora 43.

---

## 1. Disable Unused GNOME Extensions

Extensions run inside the `gnome-shell` process itself. Because GNOME Shell is a
single-process compositor, a poorly written or heavy extension can cause memory
growth that never gets freed until you log out.

Open the Extensions app:

```bash
gnome-extensions-app
```

Turn off any extension you don't actively use. There is no safe shortcut here — what
counts as "unused" is personal.

---

## 2. PackageKit

On Fedora 44, GNOME Software ships a direct DNF5 plugin (`libgs_plugin_dnf5.so`) and
no longer routes RPM operations through PackageKit. Disabling or removing PackageKit
has no effect on GNOME Software's ability to install or update packages — contrary to
what older guides suggest.

PackageKit is still used by **Cockpit** (the web admin panel) and some third-party
tools. If you don't use those, you can disable it:

```bash
sudo systemctl disable --now packagekit.service
```

This does **not** break GNOME Software update notifications or RPM management — that
now lives in the DNF5 plugin directly.

---

## 3. ABRT (Automated Bug Reporting Tool)

On **Fedora 44 Workstation, `gnome-abrt` was already removed** before release. The
upstream retrace server also does not support Fedora 43 or Fedora 44 crash reports,
meaning even the CLI components are non-functional for report submission. ABRT is
effectively inert on this release.

The remaining daemon still runs in the background collecting crash data that goes
nowhere. Safe to remove entirely:

```bash
sudo dnf5 remove abrt abrt-desktop abrt-gui abrt-libs libreport \
    libreport-gtk libreport-fedora 2>/dev/null || true
```

The `2>/dev/null || true` handles any packages from the list that aren't installed on
your system — Fedora 44 may already be missing several of them.

---

## 4. SSSD

**Check your authselect profile before touching anything:**

```bash
authselect current
```

Since Fedora 40, fresh installs use the `local` profile by default — not the `sssd`
profile. If your output shows `Profile ID: local`, SSSD is not handling your
authentication and the packages can be safely removed:

```bash
sudo dnf5 remove sssd sssd-common sssd-client sssd-kcm
```

If your output shows `Profile ID: sssd`, **do not remove SSSD**. Your system is
depending on it for authentication. This is common on systems upgraded from Fedora 39
or earlier, or in enterprise environments.

The `esc` and `openct` packages (smart card tools) are safe to remove on any
standalone workstation:

```bash
sudo dnf5 remove esc openct 2>/dev/null || true
```

---

## 5. Location Services (geoclue2)

Geoclue is a D-Bus activated service — it only runs when an application explicitly
requests location information, and every app requires explicit user permission.

**Do not remove geoclue2.** It is a soft dependency of GNOME features including:
- Night Light (automatic color temperature by time of sunset)
- GNOME Clocks showing local sunset/sunrise
- GNOME Weather

The correct approach is to disable location services via GNOME Settings:

**Settings → Privacy & Security → Location Services → Off**

This disables it system-wide without removing the package. The daemon will not be
queried by any application.

---

## 6. Virtual Machine Guest Tools

If Fedora is installed on bare metal, these can be removed:

```bash
sudo dnf5 remove qemu-guest-agent spice-vdagent open-vm-tools 2>/dev/null || true
```

Use `|| true` since not all are installed by default — only the applicable one is
pulled in depending on whether the installer detected a VM environment.

---

## 7. Clean Up Leftover Dependencies

After any package removal, run:

```bash
sudo dnf5 autoremove
```

---

## 8. Background Services to Disable

These services are safe to disable if the relevant hardware or use case doesn't apply.
All commands are idempotent — running them on an already-disabled service is harmless.

### Bluetooth (if unused)

```bash
sudo systemctl disable --now bluetooth.service
```

If you use Bluetooth occasionally, prefer leaving it enabled and toggling it from the
quick settings panel instead.

### Printing (CUPS)

```bash
sudo systemctl disable --now cups.service cups.socket cups.path
```

CUPS uses socket activation, so all three units need to be disabled. Re-enable them
if you add a printer later.

### Network device discovery (Avahi / mDNS)

```bash
sudo systemctl disable --now avahi-daemon.service avahi-daemon.socket
```

Avahi handles `.local` hostname resolution and service discovery. Disable it if you
don't use network printers, AirPlay, or share files on a local network.

### Cellular modem support

```bash
sudo systemctl disable --now ModemManager.service
```

Only needed if you have a USB or built-in cellular modem.

### Legacy RAID and iSCSI monitoring

These are enterprise storage services unlikely to be running on a workstation. Check
they actually exist before disabling:

```bash
# Check which ones are present
systemctl status mdmonitor.service iscsi.service iscsid.socket 2>/dev/null

# Disable what's present
sudo systemctl disable --now mdmonitor.service 2>/dev/null || true
sudo systemctl disable --now iscsi.service iscsid.socket 2>/dev/null || true
```

---

## 9. Recovering a Bloated gnome-shell

**`Alt+F2 → r` does not work on Wayland**, and Fedora 44 ships GNOME 50 as a
Wayland-only session. Triggering a shell restart kills the compositor, which terminates
all open applications. There is no safe in-session shell restart on Wayland.

**What actually works:**

- **Log out and back in.** This is the correct equivalent — GNOME Shell is a fresh
  process after login, starting with a clean heap.
- **Switch to a TTY if the session is frozen:** Press `Ctrl+Alt+F3`, log in, then
  run `sudo systemctl restart gdm` to kill and respawn the session. Save your work
  first if possible.

---

## 10. On Dropping Disk Cache (`vm.drop_caches`)

**Do not run this routinely:**

```bash
sudo sync; sudo sysctl -w vm.drop_caches=3
```

Linux intentionally fills unused RAM with disk cache (file contents, inode data,
directory entries). This cache is what makes the system feel fast — opening a
recently-accessed file reads from RAM rather than disk. When another process needs that
RAM, the kernel silently evicts cache pages automatically. Manually dropping caches
forces an immediate rebuild from disk, costing more I/O and CPU than just letting the
kernel handle it. The "freed" RAM will be reallocated as cache within seconds of
normal use.

This command exists for benchmarking purposes (to get a clean state before measuring
cold-cache performance). It is not a memory optimization technique.

---

## 11. Summary of What's Safe vs Risky

| Action | Safe? | Condition |
|---|---|---|
| Disable PackageKit | ✔ Safe | No effect on GNOME Software on Fedora 44 |
| Remove ABRT | ✔ Safe | Already broken on Fedora 44 |
| Remove SSSD | ⚠ Check first | Only if `authselect current` shows `local` |
| Remove smart card tools (`esc`, `openct`) | ✔ Safe | Standalone workstation |
| Remove geoclue2 | ✘ Don't | Breaks Night Light; disable via Settings instead |
| Remove VM guest tools | ✔ Safe | Bare metal only |
| Disable bluetooth | ✔ Safe | If unused |
| Disable CUPS | ✔ Safe | If no printer |
| Disable Avahi | ✔ Safe | If no local network sharing |
| Disable ModemManager | ✔ Safe | If no cellular modem |
| Disable RAID/iSCSI services | ✔ Safe | Workstation install |
| `Alt+F2 → r` shell restart | ✘ Wrong | Doesn't work on Wayland; kills session |
| `vm.drop_caches=3` | ✘ Counterproductive | Not a memory optimization |
