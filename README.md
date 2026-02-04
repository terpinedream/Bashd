```
 _               _         _   
| |__   __ _ ___| |__   __| |  
| '_ \ / _` / __| '_ \ / _` |  
| |_) | (_| \__ \ | | | (_| |_ 
|_.__/ \__,_|___/_| |_|\__,_(_)
```
*A bulk data management toolkit for any Linux distro — bash scripts for file/directory cleanup, transfer, and organization.*

![Demo](demo.gif)

### Scripts

#### [cleanup]

| Script       | Description |
|--------------|-------------|
| **cleanme**  | Clear caches: no flag = system + pacman; `-p` pacman only (root); `-s` system only (~/.cache, Trash) |
| **cram**     | Move loose files into a folder: no arg = into the single subdir; `cram /path` = into `/path` |
| **crush**    | Move CWD contents into parent and remove empty CWD; source `bashd-init.sh` so running `crush` also cds to parent (default) |
| **bfold**    | Create a new directory and move loose items into it: `bfold dirname` (files only); `bfold -a dirname` or `bfold --all dirname` (files and dirs) |
| **ufold**    | Unpack directories in CWD: `ufold` unpacks all; `ufold path` unpacks that dir (if in CWD: move; if outside CWD: copy to CWD) |
| **namechange** | Mass rename: `namechange "file.txt"` → 1_file.txt, 2_file.txt, … (underscore separator; works with nest) |
| **pull**     | Move one file/dir to parent: `pull <file>` |
| **stick**    | Create dir and move items whose name contains dir name: `stick [-i] [-w] <dir_name>`; `-i` case-insensitive, `-w` whole-word only |
| **flatten**  | Move all files from subdirs into CWD, prefix filenames with path (e.g. `a/b/file.txt` → `a_b_file.txt`); then remove empty dirs |
| **nest**     | Create subdir from filename prefix (first `_`): `prefix_rest` → `prefix/rest`; one level per run; `nest [delim]` for custom delimiter |
| **hop**      | Quick dir jumps: `hop N` = up N levels; `hop name` = nearest parent whose basename matches (case-insensitive). Source `bashd-init.sh` so `hop` also cds |
| **trim**     | Remove empty dirs, zero-byte files, `.DS_Store`, `Thumbs.db`. Prints list and asks for confirmation before deleting. `-r` recursive |
| **prefix**   | Add to loose filenames in CWD: `-d` prepend date (YYYY_MM_DD), `-p` append parent dir name, `-i` append index (001, 002, …). Flags combinable |
| **dedupe**   | Find duplicate files by content hash; keep first, move rest to `_dupes/`. `-r` to recurse into subdirs |

### [file transfer]

| Script      | Description |
|-------------|-------------|
| **archive** | Archive to remote/HDD (options: -w work, -i image, -v video, -k keys, -c crypt, -p path). Edit script or config for host/paths. |
| **bak**     | Backup CWD to a directory: `bak setup <path>` to set default; then `bak` or `bak -f`; or `bak [-f] <path>` to override; `-f` overwrites if destination not empty |
| **pullfrom** | Pull from remote: `pullfrom <remote_path> <local_path>`. Edit script for REMOTE_HOST. |
| **pushto**  | Push to remote: `pushto <local_path> <remote_path>`. Edit script for REMOTE_HOST. |
| **dotsync** | Dotfiles sync: `dotsync setup <repo>`, `pull`, `link`, `push [-m "msg"]`; config in `~/.config/bashd/dotsync.conf` (REPO=, optional PATHS=) |

### [system]

| Script   | Description |
|----------|-------------|
| **topd** | Top 3 by CPU; press 1/2/3 (or k1/k2/k3) to kill, q to quit. Ignores system-critical processes (WM, compositor, DE, pipewire, etc.). `--ignore NAME` to also ignore processes whose name contains NAME (repeatable). |
| **paclock** | Remove `/var/lib/pacman/db.lck` when pacman is stuck (run as root). *Arch/pacman only.* |

**Platform notes:** **paclock** and **cleanme** `-p` (pacman cache) are Arch/pacman-specific. On other distros, `cleanme -s` and the default (system cache only when not root) still work; paclock will report "No db.lck found" or "not found" if not on Arch.

## Overview

Run **`bashd`** to print an ASCII chart of all scripts and brief descriptions. Use **`bashd --<command>`** (e.g. `bashd --crush`) for the full description of a command.

## Installation

### Install from AUR (Arch Linux)

```bash
yay -S bashd
# or
paru -S bashd
```

After install, all commands are on your PATH. For login shells, `crush` and `hop` are set up to change directory automatically. If you use a non-login interactive shell (e.g. many terminal windows) and want `crush`/`hop` to change directory, add to your `~/.bashrc` or `~/.zshrc`:

```bash
[ -f /usr/share/bashd/bashd-init.sh ] && . /usr/share/bashd/bashd-init.sh
```

### Manual install (any Linux)

**1. Install scripts** — Copy (or symlink) all scripts into a directory on your `PATH`. Recommended:

- **`/usr/local/bin`** — user-installed tools
- **`/usr/bin`** — system-wide (typically requires root)

Copy every file from `scripts/` and the root `bashd` into one of these directories so that `crush`, `hop`, `bashd`, etc. are on your PATH.

**2. Optional: `crush` and `hop` change directory** — By default, `crush` and `hop` only print a `cd` command. To make them change directory when you run them, source the init file once in your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/bashd-init.sh
```

Replace `/path/to` with the directory where `bashd-init.sh` lives (e.g. the repo root). The init file does **not** add scripts to PATH — scripts must be installed separately as above.

See [SETUP.md](SETUP.md) for step-by-step manual setup.
