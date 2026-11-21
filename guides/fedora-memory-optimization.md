# Fedora 45 Memory & Performance Optimization (GNOME 51 / KDE Plasma 6.8)

Notes on reducing unnecessary RAM usage and background activity on Fedora
Workstation (GNOME) and Fedora KDE Plasma Desktop.

> Revalidated November 2026 against Fedora 45, GNOME 51 and Plasma 6.8
> (Wayland-only on both; commands use `dnf5`). Reference machine: Intel Core 3
> 100U, 8 GB DDR5, NVMe. Sections tagged
> **[GNOME]** / **[KDE]** are desktop-specific. Items I could not re-verify
> against Fedora 45 are marked *(recheck)*.

**Measure first.** Fedora 45 shows roughly 95 MiB more "used" memory than 44 on
an idle system, almost all of it unevictable pages in the root cgroup, not any
service. Do not chase it. Look at real consumers:

```bash
systemd-cgtop -m          # per-cgroup memory
free -h; zramctl
```

---

## 1. Desktop shell extras

**[GNOME]** Extensions run inside the `gnome-shell` process, so a leaky one
grows the compositor itself until you log out. Disable what you do not use:

```bash
gnome-extensions list --enabled
gnome-extensions disable <uuid>
```

(or the Extensions app). Re-check extension compatibility after the 50 to 51
upgrade; Extensions that do not declare 51 support are disabled.

**[KDE]** Plasma widgets, KWin scripts and effects each cost memory. Remove
unused panel widgets, and disable effects and KWin scripts you do not use in
System Settings → Window Management → Desktop Effects / KWin Scripts. Plasma
6.8 itself reduced startup memory, including the Discover update notifier.

---

## 2. PackageKit and software centres

The two desktops differ here, and the old advice only held for GNOME:

- **[GNOME]** GNOME Software talks to dnf5 directly (via the dnf5daemon, not
  PackageKit). Disabling PackageKit does not affect GNOME Software.
- **[KDE]** **Discover uses PackageKit** (since Fedora 44 PackageKit itself
  uses a DNF5 backend). If you use Discover for RPM updates or the update
  notifier, do **not** disable PackageKit.

If you update only from the terminal and Flatpak, you can save memory on KDE by
disabling Discover's notifier autostart instead (System Settings → Autostart;
Plasma 6.8 lets you toggle an entry without deleting it), and on either desktop
by stopping PackageKit:

```bash
sudo systemctl disable --now packagekit.service
```

PackageKit is also used by Cockpit and some third-party tools.

---

## 3. ABRT *(recheck on Fedora 45)*

On Fedora 44 Workstation `gnome-abrt` had already been removed and the upstream
retrace server did not accept 43/44 crash reports, leaving the ABRT daemon
collecting data that goes nowhere. List what is installed before removing:

```bash
dnf5 list --installed 'abrt*' 'libreport*'
```

```bash
sudo dnf5 remove abrt abrt-desktop abrt-gui abrt-libs libreport \
    libreport-gtk libreport-fedora 2>/dev/null || true
```

**[KDE]** crash reporting is DrKonqi, which is independent of ABRT. Keep it.

---

## 4. SSSD

Check your authselect profile first:

```bash
authselect current
```

Fresh installs since Fedora 40 use the `local` profile. If it says
`Profile ID: local`, SSSD is not authenticating you and can be removed:

```bash
sudo dnf5 remove sssd sssd-common sssd-client sssd-kcm
```

If it says `sssd`, **do not remove it**. (Fedora 45 also drops the `nis`
authselect profile; irrelevant on a standalone workstation.) Smart-card tools
are safe to remove on a standalone machine:

```bash
sudo dnf5 remove esc openct 2>/dev/null || true
```

---

## 5. Location services (geoclue2)

Geoclue is D-Bus activated: it runs only when an app asks, and each app needs
permission. **Do not remove geoclue2**; desktop features depend on it softly.

- **[GNOME]** Settings → Privacy & Security → Location Services → Off. This
  disables it system-wide without removing the package (Night Light then needs
  a manual schedule or a fixed location).
- **[KDE]** There is no single global switch in System Settings. Use manual
  location/schedule in Night Light rather than the automatic mode, and decline
  location prompts from apps. *(recheck: whether Night Light's automatic mode
  queries GeoClue on 6.8)*

---

## 6. Virtual machine guest tools

On bare metal these can be removed:

```bash
sudo dnf5 remove qemu-guest-agent spice-vdagent open-vm-tools 2>/dev/null || true
```

---

## 7. Clean up leftover dependencies

```bash
sudo dnf5 autoremove
```

Read the list before confirming; it can include packages you were relying on
only as weak dependencies.

---

## 8. Background services to disable

All commands are idempotent.

### Bluetooth (if unused)

```bash
sudo systemctl disable --now bluetooth.service
```

If you use it occasionally, keep it enabled and toggle from Quick Settings
**[GNOME]** or the Bluetooth applet **[KDE]**.

### Printing (CUPS)

```bash
sudo systemctl disable --now cups.service cups.socket cups.path cups-browsed.service
```

CUPS is socket/path activated, so disable all units. `cups-browsed` (network
printer discovery) may not exist on every install; ignore "not found" errors.

### Network discovery (Avahi / mDNS)

```bash
sudo systemctl disable --now avahi-daemon.service avahi-daemon.socket
```

Needed for `.local` names, network printers, AirPlay and some file sharing.
KDE Connect does not use Avahi.

### Cellular modem

```bash
sudo systemctl disable --now ModemManager.service
```

### Legacy RAID and iSCSI monitoring

```bash
systemctl status mdmonitor.service iscsi.service iscsid.socket 2>/dev/null
sudo systemctl disable --now mdmonitor.service 2>/dev/null || true
sudo systemctl disable --now iscsi.service iscsid.socket 2>/dev/null || true
```

### Indexer

See `fedora-setup.md` §9.2 (**[GNOME]** LocalSearch, **[KDE]** Baloo).

---

## 9. Recovering a bloated desktop shell

There is no safe in-session compositor restart on Wayland, on either desktop.
`Alt+F2 → r` does not exist on GNOME's Wayland-only session, and restarting the
compositor ends the session and every app in it.

**[GNOME]** Log out and back in (fresh `gnome-shell`, clean heap). If frozen:
switch to a TTY (`Ctrl+Alt+F3`; on Fedora 45 this is kmscon), log in, and run
`sudo systemctl restart gdm` (saves nothing; unsaved work is lost).

**[KDE]** Plasma's shell, unlike KWin, *can* be restarted without losing your
windows:

```bash
systemctl --user restart plasma-plasmashell.service
# fallback if it is not running as a systemd unit:
plasmashell --replace &
```

KWin (the compositor) cannot be restarted on Wayland. If the whole session is
frozen, use a TTY and restart the login manager:

```bash
sudo systemctl restart plasmalogin     # Fedora 44+ fresh installs
sudo systemctl restart sddm            # systems still on SDDM
```

---

## 10. On dropping disk cache (`vm.drop_caches`)

Do not run this routinely:

```bash
sudo sync; sudo sysctl -w vm.drop_caches=3
```

Linux fills unused RAM with file cache on purpose and evicts it automatically
when a process needs memory. Dropping it forces an immediate rebuild from disk,
costing more I/O and CPU than leaving it alone. It exists for benchmarking cold
caches, not as a memory optimization.

---

## 11. Swap, zram and OOM

zram, sysctl and systemd-oomd are covered in `fedora-setup.md` §2.

---

## 12. Summary: safe vs risky

| Action | Safe? | Condition |
|---|---|---|
| Disable PackageKit | ✔ GNOME / ⚠ KDE | **Breaks Discover** RPM updates on KDE |
| Remove ABRT | ✔ Safe | Recheck package list on Fedora 45 |
| Remove SSSD | ⚠ Check first | Only if `authselect current` shows `local` |
| Remove smart card tools (`esc`, `openct`) | ✔ Safe | Standalone workstation |
| Remove geoclue2 | ✘ Don't | Disable location in settings instead |
| Remove VM guest tools | ✔ Safe | Bare metal only |
| Disable bluetooth / CUPS / Avahi / ModemManager | ✔ Safe | If hardware/use case absent |
| Disable RAID/iSCSI services | ✔ Safe | Workstation install |
| `dnf5 mark remove` | ✘ Does not exist | Use `dnf5 remove` + `excludepkgs` |
| `Alt+F2 → r` | ✘ Wrong | No such restart on Wayland |
| Restart `plasma-plasmashell` | ✔ KDE only | Shell only; KWin cannot be restarted |
| `vm.drop_caches=3` | ✘ Counterproductive | Not a memory optimization |
