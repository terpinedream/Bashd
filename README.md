```
 _               _         _   
| |__   __ _ ___| |__   __| |  
| '_ \ / _` / __| '_ \ / _` |  
| |_) | (_| \__ \ | | | (_| |_ 
|_.__/ \__,_|___/_| |_|\__,_(_) (A collection of bash helper scripts for lazy sysadmins)
```


![Demo](demo.gif)

## Quick Start

```bash
# Clone
git clone https://github.com/terpinedream/Bashd.git
cd Bashd

# Run tests
make test

# Install (core + helpers by default)
sudo make install-core

# Or install everything
sudo make install-all

# Add to ~/.bashrc or ~/.zshrc:
source /usr/local/bin/bashd-scripts/bashd-init.sh
```

## Usage

All commands are available through the `bashd` dispatcher:

```bash
bashd pfx -d              # add date prefix to files
bashd recase -k            # rename to kebab-case
bashd undo                 # reverse last rename
bashd --help pfx           # show detailed help for pfx
bashd --chart              # ASCII chart of all commands
bashd --list               # list all available commands
bashd --list core          # list only core commands
```

With `bashd-init.sh` sourced, aliased commands can be used directly:

```bash
pfx -d                     # same as bashd pfx -d
hop 3                      # jump up 3 directories
trim -n                    # dry-run cleanup
```

### Alias Configuration

Control which commands get bare aliases (no `bashd` prefix needed) via `~/.config/bashd/aliases.conf`:

```bash
# One command per line. Lines starting with # are comments.
# Run 'bashd alias --default' to generate a default config.
pfx
sfx
trim
hop
lower
```

If the config file doesn't exist, all core + helper commands get aliases by default (backward compatible).

## Scripts

### Core (rename, organize, clipboard, cleanup)

| Script         | Description |
|----------------|-------------|
| **pfx**        | Prepend to filenames: `-d` date, `-p` parent dir, `-i` index. Combinable |
| **sfx**        | Append suffix before extension: `-d` date, `-p` parent, `-i` index |
| **rmpfx**      | Strip prefix segments: `-d` date, `-n N` segments, `[delim]` |
| **rmsfx**      | Strip suffix segments: `-d` date, `-n N` segments, `[delim]` |
| **recase**     | Batch rename case: `-c` camel, `-l` lower, `-u` upper, `-t` title, `-k` kebab |
| **lower**      | Sanitize filenames: lowercase, strip special chars, collapse underscores |
| **gaps**       | Re-index numbered files to fill gaps. Preserves padding |
| **namechange** | Mass rename: `namechange "file.txt"` -> 1_file.txt, 2_file.txt, ... |
| **undo**       | Reverse last rename (pfx, sfx, rmpfx, rmsfx, recase, gaps, lower, namechange) |
| **wrap**       | Move files into dir: `wrap`, `wrap <dir>`, `wrap -c <name>`, `wrap -c -a <name>` |
| **uwrap**      | Unpack directories into CWD |
| **nest**       | Split filenames at delimiter into subdirs: `prefix_rest` -> `prefix/rest` |
| **flatten**    | Move subdir files to CWD with path prefix; remove empty dirs |
| **stick**      | Create dir, move matching files: `stick [-i] [-w] <name>` |
| **split**      | Distribute files into N equal subdirectories |
| **byext**      | Sort files into extension-based subdirs |
| **bydate**     | Sort files into date-based subdirs by mtime |
| **dedupe**     | Find duplicates by hash, move to `_dupes/`. `-r` recurse |
| **trim**       | Remove junk (empty files, `.DS_Store`, empty dirs). `-r` recurse, `-n` dry run |
| **qc**         | Quick interactive file deletion with filtering |
| **bak**        | Backup files: `bak <file> ...` or `bak *` |
| **ubak**       | Restore `.bak` files: smart diff, `-k` keep original, `-r` revert |
| **clip**       | Copy file contents to clipboard |
| **clipd**      | Copy multiple files to clipboard with `# path` separators |
| **cbwrite**    | Write clipboard to file. `-f` overwrite, `-a` append |
| **cpath**      | Copy CWD or file path to clipboard |
| **cpt**        | Copy last command output to clipboard. `-y` skip confirm |
| **sized**      | Show largest files/dirs: `-d` dirs, `-r` recurse, `-n N` |
| **bring**      | Copy file or directory into CWD |
| **pull**       | Move one file/dir to parent directory |

### Helpers (cd-requiring, need bashd-init.sh)

| Script    | Description |
|-----------|-------------|
| **hop**   | Quick dir jumps: `hop N` up N levels, `hop name` match parent |
| **ndir**  | Create directory and cd into it |
| **crush** | Move CWD contents to parent, remove dir |
| **tmpws** | Temp workspace: `-c` copy CWD, `-r` return to original dir |
| **bm**    | Directory bookmarks: `-a` save, `-l` list, `-d` delete |
| **mark**  | Session breadcrumb trail: `-a` mark, `-l` list, pick and jump |
| **ld**    | Cd to last-used directory |
| **cdch**  | Cd to dir of most recently modified file |
| **qs**    | Quick nav: pick dirs, `-s` search, `-f` search files |

### Extra (niche, system-specific, personal)

| Script       | Description |
|--------------|-------------|
| **cleanme**  | Clear caches: `-p` pacman, `-s` system, or both |
| **paclock**  | Remove pacman db.lck (root) |
| **topd**     | Top 3 CPU processes; kill by number |
| **archive**  | Archive to remote/HDD |
| **bkup**     | Backup CWD to directory |
| **pullfrom** | Pull from remote |
| **pushto**   | Push to remote |
| **dotsync**  | Dotfiles sync |
| **template** | Save/recreate directory structures |
| **pland**    | Create PLAN/PLAN_NN.md for LLM prompts |

## Project Structure

```
Bashd/
  scripts/
    bashd            # dispatcher (single entry point)
    bashd-init.sh    # shell init (aliases, cd-wrappers, prompt hooks)
    _bashd_log       # shared rename logging library
    core/            # 30 core scripts (rename, organize, clipboard, cleanup)
    helpers/         # 9 cd-requiring shell helpers
    extra/           # 10 niche/system utilities
  tests/
    run_tests.sh     # test runner
    test_helpers.sh  # assertion functions
    test_*.sh        # 17 test files (65+ assertions)
  Makefile           # install/uninstall/test targets
```

## Installation

### With Make (recommended)

```bash
# Core + helpers only (most users)
sudo make install-core

# Everything including extras
sudo make install-all

# Custom prefix
sudo make install-all PREFIX=/opt/bashd

# Uninstall
sudo make uninstall
```

### Manual

Copy `scripts/bashd` to a directory on your PATH (e.g. `/usr/local/bin/bashd`), then copy the `scripts/` subdirectories to `/usr/local/bin/bashd-scripts/`.

### Shell Init

Add to `~/.bashrc` or `~/.zshrc`:

```bash
source /usr/local/bin/bashd-scripts/bashd-init.sh
```

This sets up:
- The `bashd` dispatcher on your PATH
- Shell wrappers for cd-requiring helpers (hop, crush, ld, etc.)
- Prompt hooks for `ld` (last dir) and `cpt` (last command)
- Session file cleanup on exit (mark trail, lastcmd)
- Config-driven aliases from `~/.config/bashd/aliases.conf`

## Testing

```bash
make test
# or
bash tests/run_tests.sh
# or run a specific test
bash tests/run_tests.sh test_pfx.sh
```
