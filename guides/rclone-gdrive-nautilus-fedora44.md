# Mounting Google Drive with rclone on Fedora 44 (GNOME 50 / Nautilus)

> **Target:** Fedora 44 Workstation (GNOME 50, Wayland, SELinux enforcing)
>
> **Goal:** Mount Google Drive via rclone so that Nautilus automatically shows it
> in the sidebar as a network drive — persistent across reboots, no manual steps
> after initial setup.

---

## Background

GNOME 50 dropped its native Google Drive integration via GVFS/libgdata (the
library it depended on, `libgdata`, was archived upstream after its dependency
on `libsoup2` became a dead end). As a result, the "Files" toggle in GNOME
Online Accounts no longer works on Fedora 44.

The replacement is `rclone`, which can mount Google Drive as a local FUSE
filesystem. The challenge is making Nautilus pick it up automatically in the
sidebar. This requires mounting inside `/run/media/$USER/`, which is the
conventional location that Nautilus/GIO monitors for removable and network
mounts — but `/run` is a tmpfs that is wiped on every boot.

The solution is a two-piece setup:

- **`systemd-tmpfiles`** recreates the mount directory on every boot.
- **A systemd user service** mounts the drive automatically at login.

The rclone config lives safely in `~/.config/rclone/`, which is persistent.
No root-owned processes handle the actual mount — `rclone` runs as you, in
your session.

---

## Prerequisites

- Fedora 44 Workstation (GNOME 50)
- A Google account
- A working internet connection
- A terminal

---

## Step 1 — Install rclone and fuse3

Both packages are available in the default Fedora repositories.

```bash
sudo dnf install rclone fuse3
```

Verify the installations:

```bash
rclone --version
fusermount3 --version
```

`fuse3` installs the `fusermount3` binary at `/usr/bin/fusermount3`. This is
the correct executable name on Fedora — **not** `fusermount` (that is the
older FUSE v2 binary).

---

## Step 2 — Configure rclone with Google Drive

Run the interactive configuration wizard:

```bash
rclone config
```

Follow these steps through the prompts:

1. Press `n` to create a **new remote**.
2. Name the remote. This uses **`gdrive`** as the example name throughout —
   substitute your chosen name where needed.
3. For storage type, find and select **Google Drive** (type the number shown
   next to it, or type `drive`).
4. Leave **Client ID** and **Client Secret** blank (press Enter for both) to
   use rclone's default shared credentials.
5. For **scope**, choose `1` (full access to all files).
6. Leave **root folder ID** and **service account file** blank.
7. When asked about **advanced config**, say `n`.
8. When asked to use **auto config**, say `y`. A browser window will open —
   log into your Google account and grant the requested permissions.
9. When asked about **Shared drives (Team Drives)**, say `n` unless you need
   one.
10. Confirm the configuration looks correct, then press `y` to save.

Verify the remote works:

```bash
rclone lsd gdrive:
```

You should see the top-level folders in your Google Drive.

---

## Step 3 — Enable `user_allow_other` in FUSE

By default, `fusermount3` does not allow non-root users to pass the
`--allow-other` flag, which is required for other processes running as the
same user (like Nautilus) to access the FUSE mount. Enable it by uncommenting
one line in `/etc/fuse.conf`:

```bash
sudo sed -i 's/^# *user_allow_other/user_allow_other/' /etc/fuse.conf
```

Verify the change took effect:

```bash
grep 'user_allow_other' /etc/fuse.conf
```

Expected output:

```
user_allow_other
```

---

## Step 4 — Recreate `/run/media/$USER` on every boot via `tmpfiles.d`

`/run` is a tmpfs — it is completely empty after a fresh boot. The
`systemd-tmpfiles` mechanism is specifically designed to recreate directories
and files in tmpfs locations on every boot, before any user session starts.

Create a `tmpfiles.d` drop-in file. Replace `YOUR_USERNAME` with your actual
Linux username (the output of `whoami`).

```bash
sudo tee /etc/tmpfiles.d/rclone-gdrive.conf << 'EOF'
# Type  Path                        Mode  User           Group          Age  Arg
d       /run/media/YOUR_USERNAME    0750  YOUR_USERNAME  YOUR_USERNAME  -    -
EOF
```

Apply it immediately without rebooting:

```bash
sudo systemd-tmpfiles --create /etc/tmpfiles.d/rclone-gdrive.conf
```

Confirm the directory was created:

```bash
ls -ld /run/media/YOUR_USERNAME
```

Expected output (with your username in place):

```
drwxr-x--- 2 YOUR_USERNAME YOUR_USERNAME 40 Jun  1 12:00 /run/media/YOUR_USERNAME
```

> **Why this works across reboots:** `systemd-tmpfiles-setup.service` runs
> during early boot and processes all files in `/etc/tmpfiles.d/`. Because
> `/run/media/YOUR_USERNAME` is defined there, it will be recreated on every
> boot — before you even log in.

---

## Step 5 — Create the systemd user service

Create the directory for user services if it does not already exist:

```bash
mkdir -p ~/.config/systemd/user/
```

Create the service file. This uses `%u` (username) and `%h` (home directory),
which are **systemd specifiers** expanded by systemd itself — do not confuse
them with shell variables like `$USER` or `$HOME`, which do not expand in
`ExecStart=` lines.

Also replace `gdrive` (at the end of `ExecStart`) with whatever name you gave
your remote in Step 2 if it differs.

```bash
cat > ~/.config/systemd/user/rclone-gdrive.service << 'EOF'
[Unit]
Description=Google Drive (rclone)
After=default.target

[Service]
Type=notify
# Create the actual mountpoint inside the directory that tmpfiles.d ensures exists
ExecStartPre=/usr/bin/mkdir -p /run/media/%u/gdrive
ExecStart=/usr/bin/rclone mount gdrive: /run/media/%u/gdrive \
    --config=%h/.config/rclone/rclone.conf \
    --vfs-cache-mode=full \
    --allow-other \
    --log-level=INFO \
    --log-file=%h/.cache/rclone-gdrive.log
ExecStop=/usr/bin/fusermount3 -u /run/media/%u/gdrive
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
```

**Notes on the service file:**

- `Type=notify` — rclone supports `sd_notify`, so systemd waits for rclone to
  signal that the mount is fully ready before the service is considered
  "started". Use this instead of `Type=simple`.
- `ExecStartPre` creates `/run/media/%u/gdrive` (the actual mountpoint). The
  parent `/run/media/%u` is guaranteed to exist from Step 4.
- `%h` and `%u` are systemd user-unit specifiers. They expand correctly in
  user services. Do **not** use `$HOME`, `~`, or `${HOME}` — these are shell
  variables and are not expanded in systemd `Exec*=` directives.
- `fusermount3` — this is the FUSE v3 binary on Fedora. Do not use `fusermount`
  (FUSE v2), which may not be installed.
- `--vfs-cache-mode=full` — recommended for desktop use. Files are cached
  locally before upload, which prevents partial-write errors in most apps.
- `Restart=on-failure` with `RestartSec=10` — handles the case where the
  network is not yet available at login time.

---

## Step 6 — Enable and start the service

Reload the user-level systemd daemon to pick up the new file, then enable and
start the service:

```bash
systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive.service
```

Check the status:

```bash
systemctl --user status rclone-gdrive.service
```

Expected output includes `Active: active (running)`. If you see it, open
Nautilus — Google Drive should now appear in the sidebar under the network
drives section.

---

## Step 7 — (Optional) Enable lingering

By default, the user systemd instance only runs while you are logged in. If
you want the mount to survive a graphical session logout and be ready before
you log in (e.g., for background sync scripts), enable **lingering**:

```bash
loginctl enable-linger $USER
```

For normal desktop use where you always log in before needing the drive, this
step is not required.

---

## How it all fits together

| Concern | Solution |
|---|---|
| `/run` wiped on reboot | `tmpfiles.d` recreates `/run/media/$USER` at every boot |
| Mountpoint inside that dir | `ExecStartPre=mkdir -p` recreates it on every service start |
| rclone credentials | Live in `~/.config/rclone/rclone.conf` — persistent, untouched by reboots |
| Service auto-starts | User systemd instance starts with your GNOME session |
| Nautilus picks it up | `/run/media/$USER/...` is monitored by GIO/Nautilus for network mounts |
| Tracker/indexer won't crawl it | Nautilus treats mounts under `/run/media/$USER/` as removable volumes, not local folders |

---

## Troubleshooting

### Checking logs

The service writes detailed logs to `~/.cache/rclone-gdrive.log`:

```bash
cat ~/.cache/rclone-gdrive.log
```

For systemd-level errors (startup failures, etc.):

```bash
journalctl --user -eu rclone-gdrive.service
```

### The service starts but Nautilus doesn't show the drive

Ensure `--allow-other` is in the `ExecStart` line and that Step 3 was
completed correctly:

```bash
grep 'user_allow_other' /etc/fuse.conf
```

If that line is absent or commented out, redo Step 3.

### "fusermount3: option allow_other only allowed if 'user_allow_other' is set"

This error in the logs means Step 3 was not applied. Run:

```bash
sudo sed -i 's/^# *user_allow_other/user_allow_other/' /etc/fuse.conf
systemctl --user restart rclone-gdrive.service
```

### "transport endpoint is not connected" (stale mount)

This happens when rclone exited unexpectedly but the mountpoint was not
properly cleaned up. Unmount it forcefully and restart the service:

```bash
sudo umount -l /run/media/$USER/gdrive
systemctl --user restart rclone-gdrive.service
```

### SELinux denials

On Fedora, regular desktop users run in the `unconfined_t` SELinux domain by
default, so FUSE mounts work without any SELinux modifications. If you have
customised your SELinux setup or see unexpected mount failures, check for AVC
denials:

```bash
sudo ausearch -m avc -ts recent | grep rclone
```

If denials are present, generate and install a local policy to allow them:

```bash
sudo ausearch -m avc -ts recent | audit2allow -M rclone-local
sudo semodule -i rclone-local.pp
```

### `/run/media/$USER` does not exist after reboot

The `tmpfiles.d` entry may have a typo (wrong username). Check:

```bash
cat /etc/tmpfiles.d/rclone-gdrive.conf
```

The `User` and `Group` fields must match your exact Linux username. Apply the
fix:

```bash
sudo systemd-tmpfiles --create /etc/tmpfiles.d/rclone-gdrive.conf
```

### The service fails immediately after boot with a network error

The network may not be ready when the user session starts. The `Restart=on-failure`
directive handles this automatically — systemd will retry the service until it
succeeds. You can also check whether `NetworkManager-wait-online.service` is
enabled on your system:

```bash
systemctl is-enabled NetworkManager-wait-online.service
```

---

## Uninstalling / cleaning up

To stop and disable the mount:

```bash
systemctl --user disable --now rclone-gdrive.service
```

To remove all the pieces:

```bash
# Remove the service file
rm ~/.config/systemd/user/rclone-gdrive.service

# Remove the tmpfiles.d entry (will remove /run/media/$USER on next reboot)
sudo rm /etc/tmpfiles.d/rclone-gdrive.conf

# Optionally remove the rclone remote config (this removes ALL remotes)
# rclone config delete gdrive

systemctl --user daemon-reload
```
