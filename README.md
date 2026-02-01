# Bashd

QOL helper bash scripts for Arch Linux: pacman, cleanup, file transfer, and system utilities.

## Scripts

### Pacman ([scripts/pacman/](scripts/pacman/))

| Script    | Description |
|-----------|-------------|
| **pacup** | Run full system update: `sudo pacman -Syu` (pass-through args supported) |
| **pacdown** | Reverse last pacman update using cached packages (run as root) |
| **pacfind** | Find installed package by name or keyword: `pacfind <pkg>` → list files |
| **paclist** | List installed packages: no flag = all; `-s` stable; `-e` extra/multilib; `-t` testing; `-c` changed last update; `-r` newest→oldest |
| **paclock** | Remove `/var/lib/pacman/db.lck` when pacman is stuck (run as root) |
| **mirrord** | Rank pacman mirrors by speed and save to mirrorlist (reflector/rankmirrors): `mirrord [-n N] [-c CC] [--list-only]`; optional config in `~/.config/bashd/mirrord.conf` |

### Cleanup ([scripts/cleanup/](scripts/cleanup/))

| Script       | Description |
|--------------|-------------|
| **cleanme**  | Clear caches: no flag = system + pacman; `-p` pacman only (root); `-s` system only (~/.cache, Trash) |
| **cram**     | Move loose files into a folder: no arg = into the single subdir; `cram /path` = into `/path` |
| **crush**    | Move CWD contents into parent and remove empty CWD; source `bashd-init.sh` so running `crush` also cds to parent (default) |
| **fold**     | Create a new directory and move loose items into it: `fold dirname` (files only); `fold -a dirname` or `fold --all dirname` (files and dirs) |
| **ufold**    | Unpack directories in CWD: `ufold` unpacks all; `ufold path` unpacks that dir (if in CWD: move; if outside CWD: copy to CWD) |
| **namechange** | Mass rename: `namechange "file.txt"` → file-1.txt, file-2.txt, … (ignores dirs) |
| **pull**     | Move one file/dir to parent: `pull <file>` |

### File transfer ([scripts/fileTransfer/](scripts/fileTransfer/))

| Script      | Description |
|-------------|-------------|
| **archive** | Archive to remote/HDD (options: -w work, -i image, -v video, -k keys, -c crypt, -p path) |
| **bak**     | Backup CWD to a directory: `bak setup <path>` to set default; then `bak` or `bak -f`; or `bak [-f] <path>` to override; `-f` overwrites if destination not empty |
| **pullfrom** | Pull from remote: `pullfrom <remote_path> <local_path>` |
| **pushto**  | Push to remote: `pushto <local_path> <remote_path>` |
| **dotsync** | Dotfiles sync: `dotsync setup <repo>`, `pull`, `link`, `push [-m "msg"]`; config in `~/.config/bashd/dotsync.conf` (REPO=, optional PATHS=) |

### System ([scripts/system/](scripts/system/))

| Script  | Description |
|---------|--------------|
| **topd** | Top 3 by CPU; press 1/2/3 (or k1/k2/k3) to kill, q to quit. Ignores system-critical processes (WM, compositor, DE, pipewire, etc.). `--ignore NAME` to also ignore processes whose name contains NAME (repeatable). |

## Overview

Run **`bashd`** (from the project root, or with the root on `PATH`) to print an ASCII chart of all scripts and brief descriptions.

## Setup

**Recommended:** Source the init file once in your `~/.bashrc` or `~/.zshrc` so scripts are on `PATH` and `crush` changes to the parent directory when you run it:

```bash
source /path/to/Bashd/bashd-init.sh
```

Replace `/path/to/Bashd` with the actual path to the Bashd repo. That adds the script dirs to `PATH` and defines `crush()` so that running `crush` moves contents, removes the directory, and cds to the parent (default behavior).

**Alternative:** Add the script dirs to `PATH` manually:

```bash
export PATH="$PATH:/path/to/Bashd:/path/to/Bashd/scripts/pacman:/path/to/Bashd/scripts/cleanup:/path/to/Bashd/scripts/fileTransfer:/path/to/Bashd/scripts/system"
chmod +x bashd scripts/*/*
```

Or symlink the script directories into a single bin dir on `PATH`. Without sourcing `bashd-init.sh`, running `crush` only prints a `cd` command; use `eval $(crush)` to cd, or source the init file for the default behavior.

