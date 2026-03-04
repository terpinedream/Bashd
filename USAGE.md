# Bashd - Detailed Usage Guide

This document covers every script in the toolkit with full syntax, examples, and tips.

For quick reference, run `bashd` to see the ASCII chart, or `bashd --<command>` for a one-line description of any command.

---

## Table of Contents

- [Setup](#setup)
- [File Organization](#file-organization)
  - [cram](#cram), [fold](#fold), [ufold](#ufold), [crush](#crush)
  - [nest](#nest), [flatten](#flatten)
  - [stick](#stick), [pull](#pull), [bring](#bring)
  - [byext](#byext), [bydate](#bydate), [dedupe](#dedupe)
- [Renaming](#renaming)
  - [namechange](#namechange)
  - [prefix](#prefix), [suffix](#suffix)
  - [rmpfx](#rmpfx), [rmsfx](#rmsfx)
  - [recase](#recase), [gaps](#gaps)
  - [undo](#undo)
- [Cleanup](#cleanup)
  - [trim](#trim), [empt](#empt), [cleanme](#cleanme)
- [Navigation](#navigation)
  - [hop](#hop), [ld](#ld), [ndir](#ndir), [cdch](#cdch)
  - [tmpws](#tmpws), [qs](#qs), [bm](#bm)
- [Clipboard](#clipboard)
  - [clip](#clip), [cpath](#cpath)
- [File Transfer & Backup](#file-transfer--backup)
  - [bak](#bak), [bkup](#bkup)
  - [archive](#archive), [pullfrom](#pullfrom), [pushto](#pushto)
  - [dotsync](#dotsync)
- [System](#system)
  - [topd](#topd), [paclock](#paclock)

---

## Setup

Most scripts work standalone. Just copy or symlink them to a directory on your `PATH` (e.g. `/usr/local/bin`).

Scripts that change your shell's working directory (`crush`, `hop`, `ld`, `ndir`, `cdch`, `tmpws`, `qs`, `bm`) require sourcing the init file in your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/Bashd/scripts/bashd-init.sh
```

If you symlink scripts to `/usr/bin`, make sure `_bashd_log` is also symlinked there (it's needed by all rename scripts for undo support).

---

## File Organization

### cram

Move loose files into a directory.

```
cram                  Move loose files into the single subdir in CWD
cram /path/to/dir     Move loose files into the specified directory
```

**Example:** You have a folder with `photos/` and a dozen stray `.jpg` files. Run `cram` and they all go into `photos/`.

```
$ ls
photos/  IMG_001.jpg  IMG_002.jpg  IMG_003.jpg
$ cram
✓ Moved loose files into photos/
```

If CWD has multiple subdirectories, you must specify which one: `cram photos`.

---

### fold

Create a new directory and move loose items into it.

```
fold <dirname>        Create dir, move only files into it
fold -a <dirname>     Create dir, move files and directories into it
```

**Example:** Wrap everything in CWD into a new folder.

```
$ ls
report.pdf  notes.txt  data.csv
$ fold project
✓ Created project/ and moved 3 item(s) into it
$ ls
project/
```

---

### ufold

Unpack directories -- the reverse of fold.

```
ufold                 Unpack all subdirectories into CWD
ufold <path>          Unpack one directory (move if in CWD, copy if outside)
```

**Example:**

```
$ ls
project/
$ ufold
$ ls
report.pdf  notes.txt  data.csv
```

---

### crush

Move CWD contents to parent directory and remove the now-empty CWD. Requires `bashd-init.sh` so your shell also `cd`s to the parent.

```
crush                 No arguments
```

**Example:** You realize a folder is unnecessary and want to "unwrap" it.

```
~/projects/wrapper/app $ crush
✓ Moved contents to parent and removed wrapper
~/projects/app $
```

Safety: refuses to run in `/` or `$HOME`.

---

### nest

Organize files into subdirectories by their filename prefix (split at the first delimiter).

```
nest                  Default delimiter: _
nest <delim>          Custom delimiter
```

**Example:**

```
$ ls
photo_beach.jpg  photo_city.jpg  doc_report.pdf  doc_budget.pdf  notes.txt
$ nest
✓ Nested files by first '_' into subdirs (one level)
$ ls
doc/  photo/  notes.txt
```

Files without the delimiter (`notes.txt`) are left in place. Works with `flatten` as a round-trip.

---

### flatten

Move all files from subdirectories into CWD, prefixing each filename with its path.

```
flatten               No arguments
```

**Example:**

```
$ ls
photo/  doc/  notes.txt
$ flatten
✓ Flattened 4 file(s) into CWD and removed empty directories
$ ls
doc_budget.pdf  doc_report.pdf  notes.txt  photo_beach.jpg  photo_city.jpg
```

This is the reverse of `nest` -- filenames are restored exactly.

---

### stick

Create a directory and move items whose name contains a given string.

```
stick <name>          Case-sensitive, substring match
stick -i <name>       Case-insensitive match
stick -w <name>       Whole-word match only
stick -i -w <name>    Combine flags
```

**Example:**

```
$ ls
vacation_photo.jpg  vacation_video.mp4  work_report.pdf
$ stick vacation
✓ Created vacation/ and moved 2 item(s)
$ ls
vacation/  work_report.pdf
```

---

### pull

Move one file or directory to the parent directory.

```
pull <file_or_dir>
```

**Example:**

```
~/projects/app $ pull config.json
~/projects $ ls
app/  config.json
```

---

### bring

Copy a file or directory into CWD. The opposite of `pull`.

```
bring <path>
```

**Example:**

```
$ bring ~/templates/Makefile
✓ Copied Makefile into CWD
```

---

### byext

Sort files into subdirectories by their file extension.

```
byext                 No arguments
```

**Example:**

```
$ ls
photo.jpg  report.pdf  data.csv  readme
$ byext
$ ls
csv/  jpg/  noext/  pdf/
```

Files with no extension go into `noext/`.

---

### bydate

Sort files into subdirectories by modification date.

```
bydate                Organize into YYYY/MM/DD
bydate -M             Organize into YYYY/MM only
```

**Example:**

```
$ bydate
$ ls
2025/  2026/
$ ls 2026/03/04/
report.pdf  photo.jpg
```

---

### dedupe

Find duplicate files by content hash and move extras to `_dupes/`.

```
dedupe                Direct children only
dedupe -r             Recurse into subdirectories
```

Keeps the first occurrence in place. Duplicates are moved to `_dupes/` with disambiguated names. Uses `sha256sum` (or `shasum -a 256` as fallback).

---

## Renaming

All rename scripts support **undo** -- see [undo](#undo) below.

### namechange

Mass rename all files to a numbered template.

```
namechange <template>
```

**Example:**

```
$ ls
IMG_8842.jpg  DSC_0019.jpg  photo.jpg
$ namechange "vacation.jpg"
✓ Renamed 3 file(s) to N_vacation.jpg
$ ls
1_vacation.jpg  2_vacation.jpg  3_vacation.jpg
```

The underscore separator is intentional -- these files work directly with `nest` to organize into numbered subdirs.

---

### prefix

Add prefixes to filenames. Flags are combinable.

```
prefix -d             Prepend date (YYYY_MM_DD_filename.ext)
prefix -p             Append parent directory name
prefix -i             Append incremental index (001, 002, ...)
prefix -d -i          Combine: date prefix + index suffix
```

**Example:**

```
$ ls
photo.jpg  report.pdf
$ prefix -d -i
✓ Prefixed 2 file(s)
$ ls
2026_03_04_photo_001.jpg  2026_03_04_report_002.pdf
```

---

### suffix

Add suffixes before the file extension. Same flags as prefix.

```
suffix -d             Append date (filename_YYYY_MM_DD.ext)
suffix -p             Append parent directory name
suffix -i             Append index (filename_001.ext)
```

**Example:**

```
$ ls
photo.jpg  report.pdf
$ suffix -i
✓ Suffixed 2 file(s)
$ ls
photo_001.jpg  report_002.pdf
```

---

### rmpfx

Remove prefix segments from filenames at a delimiter. Reverses `prefix` and works well after `flatten`.

```
rmpfx                 Strip 1 prefix segment (default _ delimiter)
rmpfx -n N            Strip N prefix segments
rmpfx <delim>         Custom delimiter
rmpfx -n 3 "-"        Strip 3 segments at - delimiter
```

**Example:**

```
$ ls
2026_03_04_photo.jpg  2026_03_04_report.pdf  notes.txt
$ rmpfx
✓ Stripped prefix from 2 file(s)
$ ls
03_04_photo.jpg  03_04_report.pdf  notes.txt

$ rmpfx -n 2
✓ Stripped prefix from 2 file(s)
$ ls
photo.jpg  report.pdf  notes.txt
```

Files without enough delimiter segments are skipped.

---

### rmsfx

Remove suffix segments from filenames at a delimiter (before the extension). Reverses `suffix`.

```
rmsfx                 Strip 1 suffix segment (default _ delimiter)
rmsfx -n N            Strip N suffix segments
rmsfx <delim>         Custom delimiter
```

**Example:**

```
$ ls
photo_001.jpg  report_002.pdf  notes.txt
$ rmsfx
✓ Stripped suffix from 2 file(s)
$ ls
photo.jpg  report.pdf  notes.txt
```

---

### recase

Batch rename files to a target naming convention. Intelligently splits words on `_`, `-`, spaces, and camelCase boundaries.

```
recase -l             lowercase     (my_cool_photo.jpg)
recase -u             UPPERCASE     (MY_COOL_PHOTO.jpg)
recase -c             camelCase     (myCoolPhoto.jpg)
recase -t             Title_Case    (My_Cool_Photo.jpg)
recase -k             kebab-case    (my-cool-photo.jpg)
```

Extensions always stay lowercase. Exactly one flag required.

**Example:**

```
$ ls
My_Vacation_Photo.jpg  Work_Report_Draft.pdf
$ recase -k
✓ Recased 2 file(s) to kebab
$ ls
my-vacation-photo.jpg  work-report-draft.pdf
```

Works on any input convention -- underscores, hyphens, camelCase, or mixed:

| Input | `-l` | `-k` | `-c` |
|---|---|---|---|
| `My_Cool_Photo` | `my_cool_photo` | `my-cool-photo` | `myCoolPhoto` |
| `myCoolPhoto` | `my_cool_photo` | `my-cool-photo` | `myCoolPhoto` |
| `song-remix-final` | `song_remix_final` | `song-remix-final` | `songRemixFinal` |

---

### gaps

Re-index numbered files to fill gaps in the sequence.

```
gaps                  Default delimiter _
gaps <delim>          Custom delimiter
```

Detects numbers at the first or last delimiter boundary. Preserves padding width. Files without a numeric segment and single-file groups are skipped.

**Example:**

```
$ ls
chapter_01.txt  chapter_05.txt  chapter_09.txt  notes.txt
$ gaps
✓ Re-indexed 2 file(s)
$ ls
chapter_01.txt  chapter_02.txt  chapter_03.txt  notes.txt
```

Also works with prefix-style numbering:

```
$ ls
01_photo.jpg  05_photo.jpg  09_photo.jpg
$ gaps
$ ls
01_photo.jpg  02_photo.jpg  03_photo.jpg
```

---

### undo

Reverse the last rename operation. Works with `prefix`, `suffix`, `rmpfx`, `rmsfx`, `recase`, `namechange`, and `gaps`.

```
undo                  No arguments; must be in the same directory
```

Single-level undo -- each rename overwrites the previous log. The log is stored in `~/.config/bashd/last_rename`.

**Example:**

```
$ recase -k
✓ Recased 5 file(s) to kebab
$ undo
✓ Reversed 5 rename(s) from recase
```

If you run `undo` from the wrong directory, it tells you where to go:

```
$ undo
✗ Wrong directory. The last rename (recase) was in:
  /home/user/photos
  cd there and run undo again.
```

---

## Cleanup

### trim

Safely remove junk files and empty directories.

```
trim                  Direct children only
trim -r               Recursive
```

Targets: zero-byte files, `.DS_Store`, `Thumbs.db`, empty directories. Always prints a list and asks for confirmation before deleting.

---

### empt

Dry run for `trim` -- shows what would be removed without deleting anything.

```
empt                  Direct children only
empt -r               Recursive
```

---

### cleanme

Clear system caches.

```
cleanme               Both system and pacman caches
cleanme -s            System only (~/.cache, Trash)
cleanme -p            Pacman only (requires root)
```

---

## Navigation

All navigation scripts require `bashd-init.sh` to be sourced so they can change your shell's working directory.

### hop

Quick directory jumps -- up by count or by name.

```
hop <N>               Go up N directory levels
hop <name>            Jump to nearest parent with matching basename
```

**Example:**

```
~/projects/app/src/components $ hop 3
~/projects $

~/projects/app/src/components $ hop projects
~/projects $
```

Name matching is case-insensitive.

---

### ld

Jump to your last working directory (the one you were in before your most recent `cd`).

```
ld                    No arguments
```

The init file tracks your CWD on each prompt. `ld` reads the saved path and jumps back.

---

### ndir

Create a directory and immediately `cd` into it.

```
ndir <name>
```

**Example:**

```
$ ndir new-project
$ pwd
/home/user/new-project
```

---

### cdch

Jump to the directory containing the most recently modified file. Useful after downloading something.

```
cdch                  No arguments
```

Searches `~/Downloads`, `~/Desktop`, and CWD by default. Override with `CDCH_DIRS`.

**Example:** Download a file in Firefox, then:

```
$ cdch
Recently changed: document.pdf
~/Downloads $
```

---

### tmpws

Create a temporary workspace that auto-deletes when your shell exits.

```
tmpws                 Create empty temp dir and cd into it
tmpws -c              Copy CWD contents into the temp dir first
```

**Example:** Experiment with files safely:

```
$ tmpws -c
$ ls
(copies of your files)
$ # experiment freely...
$ exit
# temp dir is automatically removed
```

---

### qs

Interactive quick navigation with directory picker, search, and file opener.

```
qs                    Pick from common dirs (Home, Documents, Downloads, etc.) and drill down
qs -s <pattern>       Fuzzy search directories by name
qs -f <pattern>       Search for a file and open it in $EDITOR
```

---

### bm

Directory bookmarks -- save, list, jump to, and delete named locations.

```
bm -a <name>              Bookmark CWD as <name>
bm -a <dir> <name>        Bookmark a specific directory as <name>
bm <name>                 Jump to bookmark
bm -l                     List all bookmarks
bm -d <name>              Delete a bookmark
```

Names can be numbers or strings.

**Example:**

```
$ cd ~/Documents/git/myproject
$ bm -a proj
✓ Bookmarked 'proj' → /home/user/Documents/git/myproject

$ cd /tmp
$ bm proj
~/Documents/git/myproject $

$ bm -l
  proj         /home/user/Documents/git/myproject
```

Bookmarks persist in `~/.config/bashd/bookmarks`.

---

## Clipboard

### clip

Copy a file's contents to the clipboard.

```
clip <filename>
```

Auto-detects clipboard tool: `wl-copy`, `xclip`, `xsel`, `pbcopy`, or `clip.exe`.

---

### cpath

Copy a path to the clipboard.

```
cpath                 Copy CWD's absolute path
cpath <file_or_dir>   Copy that item's absolute path
```

---

## File Transfer & Backup

### bak

Quick single-file backup. Creates a `.bak` copy and keeps a working original.

```
bak <filename>
```

**Example:**

```
$ bak config.yaml
$ ls
config.yaml  config.yaml.bak
```

The original is renamed to `.bak` and a fresh copy becomes the working file.

---

### bkup

Backup the current directory to a destination.

```
bkup setup <path>     Save a default backup destination
bkup                  Backup CWD to the saved destination
bkup <path>           Backup CWD to a specific path
bkup -f               Force overwrite if destination is not empty
bkup -f <path>        Force + specific path
```

Config stored in `~/.config/bashd/bkup_dest`.

---

### archive

Archive files to a remote host or external drive.

```
archive -w            Work files
archive -i            Images
archive -v            Video
archive -k            Keys
archive -c            Encrypted volume
archive -p <src> <dst>  Custom source and destination paths
```

Requires editing `REMOTE_HOST` and `ARCHIVE_BASE` in the script to match your setup.

---

### pullfrom / pushto

Simple SCP wrappers for transferring files to/from a remote host.

```
pullfrom <remote_path> <local_path>
pushto <local_path> <remote_path>
```

Requires editing `REMOTE_HOST` in each script.

---

### dotsync

Dotfiles manager -- clone, symlink, and sync a dotfiles repo.

```
dotsync setup <repo>         Clone/set repo path
dotsync pull                 Git pull the repo
dotsync link                 Symlink dotfiles to home
dotsync push [-m "message"]  Commit and push changes
```

Config in `~/.config/bashd/dotsync.conf`:

```
REPO=/path/to/dotfiles
PATHS=(~/.bashrc ~/.config/nvim)   # optional; defaults to all files in repo
```

---

## System

### topd

Interactive process monitor showing the top 3 CPU consumers.

```
topd                          Default
topd --ignore <name>          Also ignore processes matching <name> (repeatable)
```

Press `1`, `2`, or `3` to kill the corresponding process. Press `q` to quit. System-critical processes (window manager, compositor, pipewire, etc.) are automatically excluded.

---

### paclock

Remove the pacman lock file when it gets stuck.

```
sudo paclock
```

Simply removes `/var/lib/pacman/db.lck`. Must be run as root.

---

## Composable Workflows

These scripts are designed to chain together. A few common patterns:

**Organize → Flatten round-trip:**

```
nest → flatten           Files come back with original names
```

**Number → Organize → Restore:**

```
namechange "doc.txt" → nest → flatten → rmpfx
```

**Batch rename → Undo safety net:**

```
recase -k → undo         Any rename can be reversed
prefix -d -i → undo
```

**Clean up numbered sequences:**

```
# Delete some files, then:
gaps                      Fill the numbering holes
```

**Clipboard workflow:**

```
cpath                     Copy CWD path for pasting elsewhere
clip README.md            Copy file contents to clipboard
```
