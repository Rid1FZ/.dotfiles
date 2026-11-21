# Mounting Google Drive with rclone on Fedora 45 (GNOME 51 / KDE Plasma 6.8)

> **Target:** Fedora 45 Workstation (GNOME 51, Nautilus) or Fedora KDE Plasma
> Desktop (Plasma 6.8, Dolphin); Wayland; SELinux enforcing. Same steps work on
> Fedora 44. Checked against rclone 1.76.0 (2026-11-06) docs and changelog.
>
> **Goal:** Mount Google Drive via rclone, persistent across reboots, visible in
> the file manager with no manual steps after the initial setup; optionally also
> serve it as a local WebDAV server (Part 2).

> **Important change (2026): you now need your own Google OAuth client ID.**
> rclone's built-in shared Google Drive `client_id` is being retired because
> Google will charge for API traffic on it ("later in 2026, following 90 days of
> notice", per rclone's July 2026 announcement). Google has not published the
> exact date, and rclone's maintainer said in September that Google had gone
> quiet and might revise the plan, but rclone 1.75+ already warns when you use
> the shared ID. Treat creating your own ID (Step 2) as mandatory, not optional.

---

## Background

**GNOME.** GNOME 50 dropped its native Google Drive integration: `libgdata`
was unmaintained and archived, GVFS disabled the dependency, and GNOME Online
Accounts no longer offers the "Files" toggle for Google. GNOME 51's release
notes do not restore it. Mail, calendar and contacts through Online Accounts
are unaffected. *(recheck on your install: Settings → Online Accounts → Google
should still show no Files toggle.)*

**KDE.** `kio-gdrive` still ships in KDE Gear 26.08 (Dolphin: Network → Google
Drive after adding the account in System Settings → Online Accounts), but
"access denied" reports after a successful login exist in KDE's bug tracker
(for example bug 510280, closed as a duplicate of 480779), so it cannot be
assumed to work. rclone is the more predictable option on both desktops.

The replacement is `rclone`, which mounts Google Drive as a FUSE filesystem.
The remaining problem is making the file manager show it automatically:

- **Nautilus** watches `/run/media/$USER/` for mounts and lists them in the
  sidebar.
- **Dolphin** lists only Solid/udisks devices in Places, so a FUSE mount does
  **not** appear by itself. Add it once (Step 8); the entry then persists.

`/run` is a tmpfs wiped every boot, so the setup has two pieces:

- **`systemd-tmpfiles`** recreates the mount parent directory on every boot.
- **A systemd user service** mounts the drive at login.

The rclone config lives in `~/.config/rclone/` (persistent). rclone runs as
you; no root process handles the mount.

---

## Prerequisites

- Fedora 45 (GNOME 51 or KDE Plasma 6.8)
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

rclone releases often and its security fixes matter here. Use **1.75.2 or
newer** (1.76.0 is current as of 2026-11-06): 1.75.2 fixes a path traversal in
`rclone serve webdav` and requires authentication for `OPTIONS` requests, and
1.76.0 fixes a timing leak that revealed valid usernames. If the Fedora package
is older, install the upstream RPM from <https://rclone.org/downloads/> and
verify its signed `SHA256SUMS` first (Fedora 45 refuses RPMs whose signing key
is not imported, so `sudo dnf install ./rclone-*.rpm` is the right way to
install it). Check what you have against upstream:

```bash
rclone version --check
```

Avoid `rclone selfupdate` on anything older than 1.75.2; its hash check was
fixed in that release.

`fuse3` installs the `fusermount3` binary at `/usr/bin/fusermount3`. This is
the correct executable name on Fedora — **not** `fusermount` (that is the
older FUSE v2 binary).

---

## Step 2 — Create your own Google OAuth client ID

Google's console UI changes often. The authoritative steps are in the rclone
docs, <https://rclone.org/drive/#making-your-own-client-id>; this is the
current short form as of November 2026.

1. In the [Google Cloud Console](https://console.cloud.google.com/), create a
   project (any unique name, for example `rclone-yourname`).
2. **APIs & Services → Library**: enable the **Google Drive API**.
3. **Google Auth Platform → Get started**: app name `rclone`, your email as
   support email, Audience **External**, your email as contact.
4. **Branding**: Google now requires a **homepage URL** and a **privacy policy
   URL** before the app can be published. Reports on the rclone forum say a
   placeholder such as `https://example.com` is accepted for publishing; a
   verified-branding checkmark (no warning triangle) needs a domain you own.
   For a personal client the placeholder is enough to publish, but Google could
   tighten this later.
5. **Data Access → Add or remove scopes**: add
   `https://www.googleapis.com/auth/docs`,
   `https://www.googleapis.com/auth/drive` and
   `https://www.googleapis.com/auth/drive.metadata.readonly`, then **Update**
   and **Save**.
6. **Audience → Publish app**. Do not skip this: a project left in *Testing*
   gets refresh tokens that expire after **7 days**.
7. **Clients → Create client**: type **Desktop app**, name `rclone`. Copy the
   client ID and secret.

**Caveats (all from Google/rclone discussions, not rclone guarantees):**

- The app stays *unverified*: expect an "unverified app" screen when you
  authorize (choose Advanced → continue), and a cap of 100 users per
  unverified app (irrelevant for personal use).
- Google states unused OAuth clients may be deleted after 6 months of
  inactivity; keep using the remote.
- **Google Advanced Protection Program accounts** block unverified apps that
  request Drive scopes, so a personal client ID will not work for them.
- Use your own client ID on your own accounts only. Sharing it links those
  accounts to your project.

---

## Step 2B — Configure the rclone remote

**Existing remote** (created before you had your own client ID): check whether
it uses the shared ID, then switch it.

```bash
rclone config show gdrive:      # client_id and client_secret must be set
systemctl --user stop rclone-gdrive.service 2>/dev/null
rclone config                   # e, pick gdrive, enter client_id / client_secret
rclone config reconnect gdrive: # answer "Y" to "Already have a token - refresh?"
```

Without the `reconnect`, rclone keeps using the old token and shared ID.
Service-account remotes need no change.

**New remote:**

```bash
rclone config
```

1. Press `n` to create a **new remote**.
2. Name it. This guide uses **`gdrive`**; substitute yours where needed.
3. Storage type: **Google Drive** (type the number shown, or `drive`).
4. Paste your **client_id** and **client_secret** from Step 2. Recent rclone
   warns in the wizard if you leave them blank.
5. **Scope**: `1` (full access).
6. Leave **root folder ID** and **service account file** blank.
7. **Advanced config**: `n`.
8. **Auto config**: `y`. A browser opens; sign in and approve (continue past
   the unverified warning).
9. **Shared drives (Team Drives)**: `n` unless you need one.
10. Confirm and save with `y`.

Verify:

```bash
rclone lsd gdrive:
```

You should see your top-level Drive folders. Google Docs/Sheets/Slides are
exported on the fly (docx/xlsx/pptx by default) and show an unknown size;
rclone 1.74.4+ warns when a Google document cannot be exported and skips it.
Add `--drive-skip-gdocs` to the mount or server to hide Google documents
entirely.

---

## Step 3 — (Optional) Enable `user_allow_other` in FUSE

`--allow-other` lets users **other than the one who mounted** the filesystem
(and root) access it. For a single-user desktop you do not need it: Nautilus,
Dolphin and your apps all run as you. The earlier revision of this guide said
it was required; rclone's mount docs describe it only as "Allow access to other
users", and users report Plasma works without it. The service below therefore
**omits** it, so you can skip this step.

Only if you later need other accounts or root to see the mount (or a helper
fails with permission errors), enable it by uncommenting one line in
`/etc/fuse.conf`, then add `--allow-other` to `ExecStart`:

```bash
sudo sed -i 's/^# *user_allow_other/user_allow_other/' /etc/fuse.conf
grep 'user_allow_other' /etc/fuse.conf
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
    --cache-dir=%C/rclone-mount \
    --vfs-cache-mode=full \
    --vfs-cache-max-size=2G \
    --vfs-cache-max-age=24h \
    --log-level=INFO \
    --log-file=%C/rclone-gdrive.log
ExecStop=/usr/bin/fusermount3 -uz /run/media/%u/gdrive
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
- `--cache-dir=%C/rclone-mount` gives this mount its own VFS cache
  (`%C` is `~/.cache`). rclone's docs warn that two rclone processes must not
  share a VFS cache when the remotes overlap and `--vfs-cache-mode` is above
  `off`; the WebDAV server in Part 2 uses a different directory for that
  reason. systemd units have no `$HOME`/`$XDG_CACHE_HOME`, which is why the
  directory is explicit (rclone's systemd docs recommend explicit `--config`
  and `--cache-dir`).
- `--vfs-cache-max-size` / `--vfs-cache-max-age` keep the cache bounded; raise
  them if you have spare disk. The size limit is only checked periodically and
  open files cannot be evicted, so it can be briefly exceeded.
- Do not add `--rc` to this unit. rclone's remote-control server has had
  several authentication fixes in 2026; if you ever enable it, set `--rc-user`
  and `--rc-pass` and keep it on localhost.
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

Expected output includes `Active: active (running)`.

- **[GNOME]** Open Nautilus; Google Drive should appear in the sidebar.
- **[KDE]** Dolphin will not list it yet; continue to Step 8.

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

## Step 8 — **[KDE]** Add the mount to Dolphin's Places

Open Dolphin, press `Ctrl+L`, go to `/run/media/YOUR_USERNAME/`, then drag the
`gdrive` folder into the Places panel (or right-click Places → Add Entry, set
the path to `/run/media/YOUR_USERNAME/gdrive`). The entry persists across
reboots and is unaffected by the mount being briefly absent at login.

Baloo does not index it: Baloo indexes only the folders in its include list
(by default your home directory), and `/run/media` is outside it. If you ever
add a path covering it, exclude the mount in System Settings → Search.

---

# Part 2 — Serving Google Drive as a WebDAV server

Part 1 (Steps 1 to 8) mounts Drive through FUSE. Part 2 runs
`rclone serve webdav`, which exposes the same remote over HTTP/WebDAV. You can
do both, or only Part 2 (then skip Steps 3, 4, 5 and 8; you still need
Steps 1 and 2).

**When WebDAV is the better fit**

- No FUSE mount: nothing under `/run/media`, no `fusermount3`, no stale-mount
  problems.
- File managers on both desktops speak WebDAV natively (Dolphin through KIO,
  Nautilus through GVFS).
- Other apps and devices that only understand WebDAV can use the same Drive.

**Trade-offs:** file-manager access is slower and less seamless than a mount
(no POSIX semantics, apps cannot open files by plain path), and it is one more
network service to secure.

---

## Step 9 — Create credentials

`rclone serve webdav` serves files **without any login by default**, and anything
on the machine that can reach the port could then read and change your whole
Drive. Always set a login, even on localhost. Use an htpasswd file with bcrypt
(rclone supports MD5, SHA1 and bcrypt; bcrypt is recommended), not
`--user/--pass`, which expose the password in the process list.

```bash
sudo dnf install httpd-tools
htpasswd -B -c ~/.config/rclone/webdav.htpasswd "$USER"
chmod 600 ~/.config/rclone/webdav.htpasswd
```

`htpasswd` prompts for the password. The file is re-read while rclone runs, so
you can add or change users without restarting.

---

## Step 10 — Create the systemd user service

```bash
cat > ~/.config/systemd/user/rclone-gdrive-webdav.service << 'EOF'
[Unit]
Description=Google Drive WebDAV server (rclone)

[Service]
Type=simple
ExecStart=/usr/bin/rclone serve webdav gdrive: \
    --addr=127.0.0.1:8081 \
    --htpasswd=%E/rclone/webdav.htpasswd \
    --realm="rclone gdrive" \
    --config=%E/rclone/rclone.conf \
    --cache-dir=%C/rclone-webdav \
    --vfs-cache-mode=writes \
    --vfs-cache-max-size=2G \
    --vfs-cache-max-age=24h \
    --dir-cache-time=5m \
    --log-level=INFO
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now rclone-gdrive-webdav.service
systemctl --user status rclone-gdrive-webdav.service
```

**Notes:**

- `--addr=127.0.0.1:8081` binds to loopback only (rclone's default is also
  localhost, but port 8080 collides with many dev servers, so 8081 is used).
  Replace `gdrive:` with `gdrive:SomeFolder` to expose just one folder.
- `%E` and `%C` are systemd specifiers for `~/.config` and `~/.cache` in user
  units.
- A separate `--cache-dir` is **required** if the Part 1 mount is also running:
  two rclone processes must not share a VFS cache (risk of corruption).
- `--vfs-cache-mode=writes` buffers uploads to disk so writes can be retried;
  reads stream directly. Use `full` if clients seek around inside large files.
- Add `--read-only` if you only browse or download; it removes the whole
  class of accidental-delete mistakes.
- Add `--drive-skip-gdocs` to hide Google Docs/Sheets/Slides, which appear as
  exported files with an unknown size that some WebDAV clients dislike.
- `Type=simple` is used because I could not confirm that `serve webdav` signals
  readiness to systemd the way `mount` does.
- Running it as a user service means no root process, no firewall change and no
  SELinux boolean is needed for loopback.

Test from a terminal:

```bash
curl -u "$USER" -i -X PROPFIND -H 'Depth: 1' http://127.0.0.1:8081/ | head -20
```

Expect `HTTP/1.1 207 Multi-Status`. Without `-u` you should get `401`. You can
also open `http://127.0.0.1:8081/` in a browser for a plain directory listing.

---

## Step 11 — Connect from the desktop

**[KDE] Dolphin:** press `Ctrl+L` and enter `webdav://127.0.0.1:8081/` (KIO
uses `webdav://` for HTTP and `webdavs://` for HTTPS). Enter your username and
password; tick the option to save them in KWallet. Then drag the location into
Places to keep it.

**[GNOME] Nautilus:** Other Locations → *Connect to Server*, enter
`dav://127.0.0.1:8081/` (or `davs://` for HTTPS), and enter your credentials;
choose to remember them (stored in the Secret Service, which is oo7 on
GNOME 51). The server then appears in the sidebar while connected. If it says
the location is not supported, install GVFS's WebDAV support
(`sudo dnf install gvfs`) and log out and in.

**Any other app:** URL `http://127.0.0.1:8081/`, username/password from Step 9.

---

## Step 12 — (Optional) Reach it from other devices on your LAN

Do not simply change `--addr` to `0.0.0.0` without TLS: Basic authentication
sends the password in clear text. If you want LAN access:

1. Get a certificate and key (for a home network, a self-signed pair or one
   from a local CA such as `mkcert`).
2. Add to `ExecStart`: `--addr=:8443 --cert=/path/server.crt --key=/path/server.key`.
   Since rclone 1.75.0, setting `--cert` and `--key` enables TLS on **all**
   `--addr` listeners, so you cannot accidentally leave a plain-HTTP one open.
3. Open the port to your LAN zone only:

```bash
sudo firewall-cmd --permanent --zone=home --add-port=8443/tcp
sudo firewall-cmd --reload
```

Never forward this port to the internet. It exposes your entire Drive behind
one password.

---

## WebDAV troubleshooting

| Symptom | Cause / fix |
|---|---|
| `401 Unauthorized` | Wrong user/password, or htpasswd file unreadable (`chmod 600`, correct owner). |
| `Address already in use` | Another service owns the port: `ss -ltnp \| grep 8081`; change `--addr`. |
| Changes made in Drive on the web do not show up | Directory cache (`--dir-cache-time`, default 5 min). Lower it or run `kill -SIGHUP $(pidof rclone)` for a flush (this signals every rclone, including the mount). |
| Uploads fail or files look empty | Use `--vfs-cache-mode=writes` or `full`; with `off` many clients cannot write. |
| Google Doc shows size 0 / fails to open | Exported Google documents have unknown size; use `--drive-skip-gdocs` or open them in Drive. |
| Logs | `journalctl --user -eu rclone-gdrive-webdav.service` |

---

## How it all fits together

| Concern | Solution |
|---|---|
| `/run` wiped on reboot | `tmpfiles.d` recreates `/run/media/$USER` at every boot |
| Mountpoint inside that dir | `ExecStartPre=mkdir -p` recreates it on every service start |
| rclone credentials | Live in `~/.config/rclone/rclone.conf` — persistent, untouched by reboots |
| Service auto-starts | User systemd instance starts with your GNOME or Plasma session |
| Nautilus picks it up | `/run/media/$USER/...` is monitored by GIO/Nautilus for mounts |
| Dolphin picks it up | Not automatic; added once to Places (Step 8) |
| WebDAV login | htpasswd (bcrypt) file, mode 600; server bound to 127.0.0.1 |
| Mount + WebDAV together | Separate `--cache-dir` for each rclone process |
| Indexer won't crawl it | LocalSearch (GNOME) and Baloo (KDE) only index configured local folders, not `/run/media` |

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

### The service starts but the file manager doesn't show the drive

**[KDE]** Dolphin never shows it automatically; see Step 8.

**[GNOME]**

Check `ls /run/media/$USER/gdrive` in a terminal first. If that works but
Nautilus shows nothing, try the optional Step 3 (`--allow-other`) and restart
the service. *(Not re-tested on Nautilus 51.)*

### "fusermount3: option allow_other only allowed if 'user_allow_other' is set"

Only appears if you added `--allow-other` (Step 3). Either remove the flag or
apply Step 3:

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

To stop and disable the mount and the WebDAV server:

```bash
systemctl --user disable --now rclone-gdrive.service rclone-gdrive-webdav.service
rm -f ~/.config/systemd/user/rclone-gdrive-webdav.service ~/.config/rclone/webdav.htpasswd
rm -rf ~/.cache/rclone-mount ~/.cache/rclone-webdav
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
