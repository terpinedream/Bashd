```
 _               _         _   
| |__   __ _ ___| |__   __| |  
| '_ \ / _` / __| '_ \ / _` |  
| |_) | (_| \__ \ | | | (_| |_ 
|_.__/ \__,_|___/_| |_|\__,_(_) (A collection of bash helper scripts for lazy sysadmins)
```


![Demo](demo.gif)

## Scripts

### [CLEANUP]

| Script       | Description |
|--------------|-------------|
| **cleanme**  | Clear caches: no flag = system + pacman; `-p` pacman only (root); `-s` system only (~/.cache, Trash) |
| **cram**     | Move loose files into a folder: no arg = into the single subdir; `cram /path` = into `/path` |
| **crush**    | Move CWD contents into parent and remove empty CWD; source `bashd-init.sh` so running `crush` also cds to parent (default) |
| **fold**     | Create a new directory and move loose items into it: `fold dirname` (files only); `fold -a dirname` or `fold --all dirname` (files and dirs) |
| **ufold**    | Unpack directories in CWD: `ufold` unpacks all; `ufold path` unpacks that dir (if in CWD: move; if outside CWD: copy to CWD) |
| **namechange** | Mass rename: `namechange "file.txt"` → 1_file.txt, 2_file.txt, … (underscore separator; works with nest) |
| **pull**     | Move one file/dir to parent: `pull <file>` |
| **bring**    | Copy a file or directory into CWD: `bring <path>`. Complements pull |
| **stick**    | Create dir and move items whose name contains dir name: `stick [-i] [-w] <dir_name>`; `-i` case-insensitive, `-w` whole-word only |
| **flatten**  | Move all files from subdirs into CWD, prefix filenames with path (e.g. `a/b/file.txt` → `a_b_file.txt`); then remove empty dirs |
| **nest**     | Create subdir from filename prefix (first `_`): `prefix_rest` → `prefix/rest`; one level per run; `nest [delim]` for custom delimiter |
| **hop**      | Quick dir jumps: `hop N` = up N levels; `hop name` = nearest parent whose basename matches (case-insensitive). Source `bashd-init.sh` so `hop` also cds |
| **ld**       | Cd to the last-used directory (previous CWD). Source `bashd-init.sh` so the shell records CWD on each prompt and `ld` changes directory |
| **ndir**     | Create a directory and cd into it: `ndir new` → `mkdir new` and cd to `new/`. Source `bashd-init.sh` so `ndir` also cds |
| **cdch**     | Cd to the directory containing the most recently modified file. Searches ~/Downloads, ~/Desktop, and CWD; ignores hidden dirs (~/.config, etc.). Prints "Recently changed: filename". Override with `CDCH_DIRS`. Source `bashd-init.sh` so `cdch` also cds |
| **tmpws**    | Create a temp directory, cd into it, and remove it when the shell exits. `-c`/`--copy`: copy CWD contents into the temp dir first (safe: excludes temp dir when run from its parent, e.g. /tmp). Source `bashd-init.sh` so `tmpws` also cds; the dir is deleted on terminal close/exit |
| **qs**       | Quick navigation: `qs` = pick from common dirs and drill down; `qs -s PATTERN` = fuzzy search dirs; `qs -f PATTERN` = search and open file in `$EDITOR`. Source `bashd-init.sh` so `qs` (and `qs -s`) cd into the chosen directory |
| **bm**       | Directory bookmarks: `bm -a [dir] <name>` to save (CWD if dir omitted); `bm <name>` to jump; `bm -l` to list; `bm -d <name>` to delete. Names can be numbers or strings. Source `bashd-init.sh` so `bm` cds |
| **clip**     | Copy a file's contents to clipboard: `clip <filename>` (uses wl-copy/xclip/xsel/pbcopy/clip.exe fallback) |
| **cpath**    | Copy a path to clipboard: `cpath` = CWD; `cpath <file_or_dir>` = that path (absolute) |
| **trim**     | Remove empty dirs, zero-byte files, `.DS_Store`, `Thumbs.db`. Prints list and asks for confirmation before deleting. `-r` recursive |
| **empt**     | List what trim would remove (dry run): zero-byte files, .DS_Store, Thumbs.db, empty dirs. `-r` recursive. No deletion |
| **prefix**   | Add to loose filenames in CWD: `-d` prepend date (YYYY_MM_DD), `-p` append parent dir name, `-i` append index (001, 002, …). Flags combinable |
| **suffix**   | Add suffix before extension: `-d` date, `-p` parent dir name, `-i` index (e.g. base_001.ext). Complements prefix |
| **rmpfx**    | Remove prefix segments at delimiter: `prefix_rest.ext` → `rest.ext`. `rmpfx [-n N] [delim]`; `-n N` strips N segments (default 1), delim default `_`. Reverses prefix/nest naming |
| **rmsfx**    | Remove suffix segments at delimiter (before extension): `base_suffix.ext` → `base.ext`. `rmsfx [-n N] [delim]`; `-n N` strips N segments (default 1), delim default `_`. Reverses suffix naming |
| **recase**   | Batch rename to target case: `-c` camelCase, `-l` lowercase, `-u` UPPERCASE, `-t` Title_Case, `-k` kebab-case. Splits words on `_` `-` space and camelCase boundaries. Extensions stay lowercase |
| **gaps**     | Re-index numbered files to fill gaps (e.g. `hello_01, hello_03, hello_05` → `hello_01, hello_02, hello_03`). Detects numeric segment at first or last delimiter boundary. `gaps [delim]`; default `_`. Preserves padding width |
| **undo**     | Reverse the last rename operation (`prefix`, `suffix`, `rmpfx`, `rmsfx`, `recase`, `namechange`, `gaps`). Must be run from the same directory. Single-level undo |
| **byext**    | Move loose files into subdirs by extension: `file.pdf` → `pdf/file.pdf`; no extension → `noext/` |
| **bydate**   | Move loose files into date dirs by mtime: default `YYYY/MM/DD`; `-M` for `YYYY/MM` only |
| **dedupe**   | Find duplicate files by content hash; keep first, move rest to `_dupes/`. `-r` to recurse into subdirs |

## [FILE TRANSFER]

| Script      | Description |
|-------------|-------------|
| **archive** | Archive to remote/HDD (options: -w work, -i image, -v video, -k keys, -c crypt, -p path) |
| **bak**     | Single-file backup: `bak <file>` renames the file to <name>.<ext>.bak and creates a copy as the original (backup + working copy) |
| **bkup**    | Backup CWD to a directory: `bkup setup <path>` to set default; then `bkup` or `bkup -f`; or `bkup [-f] <path>`; `-f` overwrites if destination not empty |
| **pullfrom** | Pull from remote: `pullfrom <remote_path> <local_path>` |
| **pushto**  | Push to remote: `pushto <local_path> <remote_path>` |
| **dotsync** | Dotfiles sync: `dotsync setup <repo>`, `pull`, `link`, `push [-m "msg"]`; config in `~/.config/bashd/dotsync.conf` (REPO=, optional PATHS=) |

## [SYSTEM]

| Script   | Description |
|----------|-------------|
| **topd** | Top 3 by CPU; press 1/2/3 (or k1/k2/k3) to kill, q to quit. Ignores system-critical processes (WM, compositor, DE, pipewire, etc.). `--ignore NAME` to also ignore processes whose name contains NAME (repeatable). |
| **paclock** | Remove `/var/lib/pacman/db.lck` when pacman is stuck (run as root) |

## Overview

Run **`bashd`** (after installing scripts to `/usr/local/bin` or `/usr/bin`) to print an ASCII chart of all scripts and brief descriptions.

## Setup

**1. Install scripts** — Copy (or symlink) all scripts into a directory on your `PATH`. Recommended:

- **`/usr/local/bin`** — user-installed tools (no root for your own copy if you use a separate prefix)
- **`/usr/bin`** — system-wide (typically requires root to copy)

Copy every script from the repo (e.g. from `scripts/`, `scripts/cleanup/`, etc.) into one of these directories so that `crush`, `hop`, `bashd`, etc. are on your `PATH`.

**2. Optional: directory-changing commands** — Scripts that change directory (`crush`, `hop`, `ld`, `ndir`, `cdch`, `tmpws`, `qs`, `bm`) only take effect in your shell if you source the init file once in your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/Bashd/bashd-init.sh
```

Replace `/path/to/Bashd` with the path to the Bashd repo (or the directory where `bashd-init.sh` lives). That defines wrapper functions so that running `crush`, `hop`, `ld`, `ndir`, `cdch`, `tmpws`, `qs`, or `bm` evals the script output and changes directory (and in the case of `tmpws`, registers an EXIT trap to remove the temp dir when the shell exits). The init file does **not** add scripts to `PATH` — scripts are expected to be installed in `/usr/bin` or `/usr/local/bin` (or elsewhere on `PATH`).


