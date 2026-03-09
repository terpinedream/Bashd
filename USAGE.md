# Bashd - Detailed Usage Guide

This document covers every script in the toolkit with full syntax, examples, and tips.

For quick reference, run `bashd` to see the ASCII chart, or `bashd --<command>` for a one-line description of any command.

---

## Table of Contents

- [Setup](#setup)
- [File Organization](#file-organization)
  - [wrap](#wrap), [uwrap](#uwrap), [crush](#crush)
  - [nest](#nest), [flatten](#flatten)
  - [stick](#stick), [pull](#pull), [bring](#bring)
  - [byext](#byext), [bydate](#bydate), [dedupe](#dedupe)
  - [split](#split)
- [Renaming](#renaming)
  - [namechange](#namechange)
  - [pfx](#pfx), [sfx](#sfx)
  - [rmpfx](#rmpfx), [rmsfx](#rmsfx)
  - [recase](#recase), [gaps](#gaps)
  - [lower](#lower)
  - [undo](#undo)
- [Cleanup](#cleanup)
  - [trim](#trim), [qc](#qc), [cleanme](#cleanme)
- [Navigation](#navigation)
  - [hop](#hop), [ld](#ld), [ndir](#ndir), [cdch](#cdch)
  - [tmpws](#tmpws), [qs](#qs), [bm](#bm), [mark](#mark)
- [Clipboard](#clipboard)
  - [clip](#clip), [clipd](#clipd), [cbwrite](#cbwrite), [cpath](#cpath), [cpt](#cpt)
- [Inspection](#inspection)
  - [sized](#sized)
- [File Transfer & Backup](#file-transfer--backup)
  - [bak](#bak), [ubak](#ubak), [bkup](#bkup)
  - [archive](#archive), [pullfrom](#pullfrom), [pushto](#pushto)
  - [dotsync](#dotsync)
- [Scaffolding](#scaffolding)
  - [template](#template), [pland](#pland)
- [System](#system)
  - [topd](#topd), [paclock](#paclock)

---

## Setup

Most scripts work standalone. Just copy or symlink them to a directory on your `PATH` (e.g. `/usr/local/bin`).

Scripts that change your shell's working directory (`crush`, `hop`, `ld`, `ndir`, `cdch`, `tmpws`, `qs`, `bm`, `mark`) require sourcing the init file in your `~/.bashrc` or `~/.zshrc`:

```bash
source /path/to/Bashd/scripts/bashd-init.sh
```

If you symlink scripts to `/usr/bin`, make sure `_bashd_log` is also symlinked there (it's needed by all rename scripts for undo support).

---

## File Organization

### wrap

Move loose files into a directory. Combines the functionality of the former `fold` and `cram`.

```
wrap                        Move loose files into the single subdir in CWD
wrap <dir>                  Move loose files into the specified directory
wrap -c <name>              Create new dir, move files into it
wrap -c -a <name>           Create new dir, move files AND directories into it
```

**Example -- into existing subdir (no args):**

```
$ ls
photos/  IMG_001.jpg  IMG_002.jpg  IMG_003.jpg
$ wrap
✓ Moved 3 loose file(s) into photos/
```

If CWD has multiple subdirectories, specify which one: `wrap photos`.

**Example -- create a new directory:**

```
$ ls
report.pdf  notes.txt  data.csv
$ wrap -c project
✓ Created project/ and moved 3 item(s) into it
$ ls
project/
```

Use `-c -a` to also move subdirectories (not just files).

---

### uwrap

Unpack directories -- the reverse of wrap.

```
uwrap                 Unpack all subdirectories into CWD
uwrap <path>          Unpack one directory (move if in CWD, copy if outside)
```

**Example:**

```
$ ls
project/
$ uwrap
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

### split

Split loose files in CWD into N roughly equal subdirectories.

```
split <N>             N must be at least 2
```

Distributes files round-robin into `part_1/`, `part_2/`, ... `part_N/`. Refuses to run if `part_*` dirs already exist.

**Example:**

```
$ ls
a.txt  b.txt  c.txt  d.txt  e.txt  f.txt  g.txt
$ split 3
✓ Split 7 file(s) into 3 parts (~2 each, 1 part(s) have 3)
$ ls
part_1/  part_2/  part_3/
$ ls part_1/
a.txt  d.txt  g.txt
$ ls part_2/
b.txt  e.txt
$ ls part_3/
c.txt  f.txt
```

Useful for batching large directories (e.g., uploading 500 photos in chunks).

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

### pfx

Add prefixes to filenames. Flags are combinable.

```
pfx -d                Prepend date (YYYY_MM_DD_filename.ext)
pfx -p                Append parent directory name
pfx -i                Append incremental index (001, 002, ...)
pfx -d -i             Combine: date prefix + index suffix
```

**Example:**

```
$ ls
photo.jpg  report.pdf
$ pfx -d -i
✓ Prefixed 2 file(s)
$ ls
2026_03_04_photo_001.jpg  2026_03_04_report_002.pdf
```

---

### sfx

Add suffixes before the file extension. Same flags as pfx.

```
sfx -d                Append date (filename_YYYY_MM_DD.ext)
sfx -p                Append parent directory name
sfx -i                Append index (filename_001.ext)
```

**Example:**

```
$ ls
photo.jpg  report.pdf
$ sfx -i
✓ Sfx'd 2 file(s)
$ ls
photo_001.jpg  report_002.pdf
```

---

### rmpfx

Remove prefix segments from filenames at a delimiter. Reverses `pfx` and works well after `flatten`.

```
rmpfx                 Strip 1 prefix segment (default _ delimiter)
rmpfx -d              Strip date prefix (YYYY_MM_DD, 3 segments)
rmpfx -n N            Strip N prefix segments
rmpfx <delim>         Custom delimiter
rmpfx -n 3 "-"        Strip 3 segments at - delimiter
```

`-d` and `-n` are mutually exclusive. With `-d`, files whose prefix doesn't look like a date are skipped automatically.

**Example -- strip a date prefix in one shot:**

```
$ ls
2026_03_09_photo.jpg  2026_03_09_report.pdf  notes.txt
$ rmpfx -d
✓ Stripped prefix from 2 file(s)
$ ls
photo.jpg  report.pdf  notes.txt
```

**Example -- strip N segments manually:**

```
$ ls
a_b_c_file.txt
$ rmpfx -n 2
✓ Stripped prefix from 1 file(s)
$ ls
c_file.txt
```

Files without enough delimiter segments are skipped.

---

### rmsfx

Remove suffix segments from filenames at a delimiter (before the extension). Reverses `sfx`.

```
rmsfx                 Strip 1 suffix segment (default _ delimiter)
rmsfx -d              Strip date suffix (YYYY_MM_DD, 3 segments)
rmsfx -n N            Strip N suffix segments
rmsfx <delim>         Custom delimiter
```

`-d` and `-n` are mutually exclusive. With `-d`, files whose suffix doesn't look like a date are skipped.

**Example -- strip a date suffix:**

```
$ ls
photo_2026_03_09.jpg  report_2026_03_09.pdf  notes.txt
$ rmsfx -d
✓ Stripped suffix from 2 file(s)
$ ls
photo.jpg  report.pdf  notes.txt
```

**Example -- strip N segments manually:**

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

### lower

Sanitize filenames: lowercase everything, replace spaces and special characters with underscores, and collapse consecutive underscores. Designed for cleaning up files from Windows, downloads, or the web.

```
lower                 No arguments; operates on loose files in CWD
```

Characters replaced with `_`: spaces, parentheses, brackets, braces, commas, apostrophes, ampersands, `+`, `@`, `!`, `#`, `$`, `%`, `^`, `=`, `~`, backticks.

Extensions are always lowercased. Supports undo.

**Example:**

```
$ ls
My File (Copy) [2].jpg  Song - Remix & Final.MP3  Photo_2026.PNG
$ lower
✓ Sanitized 3 file(s)
$ ls
my_file_copy_2.jpg  photo_2026.png  song_remix_final.mp3
```

Files that are already clean are skipped.

---

### undo

Reverse the last rename operation. Works with `pfx`, `sfx`, `rmpfx`, `rmsfx`, `recase`, `namechange`, `gaps`, and `lower`.

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
trim -n               Dry run (list what would be removed, no deletion)
trim -r -n            Recursive dry run
```

Targets: zero-byte files, `.DS_Store`, `Thumbs.db`, empty directories. Without `-n`, prints a list and asks for confirmation before deleting.

---

### qc

Quick interactive file and directory deletion. Lists items in CWD, lets you pick which to remove.

```
qc                    List all items, pick numbers to delete
qc <pattern>          Filter by case-insensitive substring first
```

**Flow:** Displays a numbered list, then prompts for space-separated numbers to delete (or `a` for all, `0` to cancel). Confirms with y/N before actual deletion.

**Example:**

```
$ qc log
Items in CWD matching 'log':
  1. debug.log
  2. error.log
  3. access.log

Enter numbers to delete (space-separated), a = all, 0 = cancel
> 1 2

Will delete 2 item(s):
  debug.log
  error.log
Confirm? [y/N] y
✓ Deleted 2 item(s)
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

### mark

Session breadcrumb trail -- drop marks as you navigate and jump back to any of them. Unlike `bm` (permanent bookmarks) or `ld` (single last-dir), this is a stack that lives only for the current terminal session.

```
mark -a               Drop a mark at CWD
mark -l               List all marks in this session
mark                  Show numbered list and pick one to jump to
```

The trail is stored in a temp file tied to your shell's PID and automatically cleaned up when the terminal exits. Requires `bashd-init.sh`.

**Example:**

```
$ cd ~/projects/app
$ mark -a
✓ Marked: /home/user/projects/app

$ cd /etc/nginx
$ mark -a
✓ Marked: /home/user/projects/app

$ cd /tmp
$ mark
Breadcrumb trail (0 = cancel):
  [1] /home/user/projects/app
  [2] /etc/nginx

Jump to: 1
~/projects/app $
```

Duplicate consecutive marks are ignored (marking the same directory twice in a row won't add a second entry).

---

## Clipboard

### clip

Copy a file's contents to the clipboard.

```
clip <filename>
```

Auto-detects clipboard tool: `wl-copy`, `xclip`, `xsel`, `pbcopy`, or `clip.exe`.

---

### clipd

Copy multiple files to clipboard, concatenated with comment-style headers showing each file's absolute path.

```
clipd <file1> [file2] ...
```

**Output format in clipboard:**

```
# /home/user/project/main.py
(contents of main.py)

# /home/user/project/utils.py
(contents of utils.py)
```

**Example:**

```
$ clipd *.py
✓ Copied 3 file(s) to clipboard

$ clipd src/main.py src/config.py
✓ Copied 2 file(s) to clipboard
```

Useful for pasting code into an LLM, a form, or a PR description.

---

### cbwrite

Write clipboard contents to a file -- the inverse of `clip`.

```
cbwrite <filename>       Write clipboard to new file (refuses if exists)
cbwrite -f <filename>    Overwrite existing file
cbwrite -a <filename>    Append to file
```

Uses `wl-paste`, `xclip -o`, `xsel -o`, `pbpaste`, or `powershell.exe` (first available).

**Example:**

```
$ cbwrite snippet.py
✓ Create: 15 line(s) → snippet.py

$ cbwrite -a notes.txt
✓ Append: 3 line(s) → notes.txt
```

---

### cpath

Copy a path to the clipboard.

```
cpath                 Copy CWD's absolute path
cpath <file_or_dir>   Copy that item's absolute path
```

---

### cpt

Copy the output of the last terminal command to the clipboard. Retrieves the command from shell history, shows it for verification, and re-runs it with output captured.

```
cpt                   Show last command, confirm, then re-run and copy output
cpt -y                Skip confirmation (re-run immediately)
```

**Example:**

```
$ ls -la /tmp
(output appears normally)

$ cpt
Last command:
  $ ls -la /tmp

Re-run and copy output to clipboard? [y/N] y
✓ Copied output (15 line(s)) to clipboard
```

Use `cpt -y` in scripts or when you're confident the command is safe to re-run.

---

## Inspection

### sized

Show the largest files or directories in CWD, ranked by size.

```
sized                 Top 10 files (direct children)
sized -d              Top 10 directories by total size
sized -r              Recursive (include files in subdirs)
sized -n N            Show top N instead of 10
```

Flags are combinable: `sized -d -n 20`, `sized -r -n 5`.

**Example:**

```
$ sized
     48M  video_raw.mp4
     12M  archive.tar.gz
    4.0K  readme.txt

$ sized -d
    120M  photos/
     48M  videos/
     12M  documents/

$ sized -r -n 3
     48M  ./videos/video_raw.mp4
     15M  ./photos/panorama.jpg
     12M  ./archive.tar.gz
```

---

## File Transfer & Backup

### bak

Create `.bak` backups. Accepts one or more files, or use `bak *` to backup everything in CWD.

```
bak <file>                Backup a single file
bak <file1> <file2> ...   Backup multiple files
bak *                     Backup all files in CWD
```

Each file is renamed to `name.ext.bak` and a fresh copy becomes the working file. Directories and existing `.bak` files are skipped automatically.

**Example:**

```
$ bak config.yaml
✓ Backed up: config.yaml → config.yaml.bak

$ bak *
✓ Backed up: app.py → app.py.bak
✓ Backed up: config.yaml → config.yaml.bak
✓ Backed up: readme.txt → readme.txt.bak

✓ Backed up 3 file(s)
```

---

### ubak

Restore or clean up `.bak` files -- the reverse of `bak`. Smart about existing originals:

- If the original **doesn't exist**: restores the `.bak` to its original name
- If the original **exists and is identical**: removes the `.bak` (redundant backup)
- If the original **exists and differs**: prompts you to choose `-k` or `-r`

```
ubak                  Process all .bak files in CWD
ubak <file.bak>       Process a single file
ubak -k               Keep original, discard .bak (you're done editing)
ubak -r               Revert: replace original with .bak (undo your edits)
ubak -f               Alias for -k (backward compatible)
```

**Example -- clean run after no edits:**

```
$ bak *
✓ Backed up 3 file(s)

$ ubak
✓ Removed: app.py.bak (identical to app.py)
✓ Removed: config.yaml.bak (identical to config.yaml)
✓ Removed: readme.txt.bak (identical to readme.txt)

✓ Processed 3 file(s)
```

**Example -- some files were edited, keep the edits:**

```
$ ubak
✗ config.yaml differs from config.yaml.bak (use -k to keep original or -r to revert to backup)
✓ Removed: app.py.bak (identical to app.py)

✓ Processed 1 file(s), 1 skipped (use -k to keep or -r to revert)

$ ubak -k
✓ Kept config.yaml, removed config.yaml.bak

✓ Processed 1 file(s)
```

**Example -- revert to the backup:**

```
$ ubak -r config.yaml.bak
✓ Reverted: config.yaml replaced with config.yaml.bak
```

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

## Scaffolding

### template

Snapshot and recreate directory structures as named templates. Useful for creating project scaffolds you reuse across multiple projects.

```
template save <name>     Snapshot CWD structure (dirs + empty files)
template <name>          Recreate template in CWD
template -l              List saved templates
template -d <name>       Delete a template
```

Templates are stored in `~/.config/bashd/templates/` as tar archives. They capture the directory tree and file names (as empty placeholder files), not file contents.

**Example -- save a project structure:**

```
$ ls
src/  tests/  docs/  Makefile  README.md  .gitignore
$ template save python-project
✓ Saved template 'python-project' (3 dir(s), 3 file(s))
```

**Example -- recreate it elsewhere:**

```
$ mkdir new-project && cd new-project
$ template python-project
✓ Created structure from template 'python-project' (3 dir(s), 3 file(s))
$ ls
src/  tests/  docs/  Makefile  README.md  .gitignore
```

**Example -- list and manage:**

```
$ template -l
Saved templates:
  python-project  (9 entries)
  node-app  (12 entries)

$ template -d node-app
✓ Deleted template 'node-app'
```

---

### pland

Create incremental plan markdown files with a structured template for LLM prompts. Each run creates the next numbered file in a `PLAN/` directory.

```
pland                    Create next PLAN/PLAN_NN.md
pland -e                 Create and open in $EDITOR
```

The template includes sections for Objective, Context, Requirements, Approach, Files to Change, Edge Cases, and Testing.

**Example:**

```
$ pland
✓ Created PLAN/PLAN_01.md

$ pland -e
✓ Created PLAN/PLAN_02.md
(opens in $EDITOR)

$ ls PLAN/
PLAN_01.md  PLAN_02.md
```

Numbering is zero-padded and auto-increments based on existing files in the `PLAN/` directory.

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
pfx -d -i → undo
```

**Clean up numbered sequences:**

```
# Delete some files, then:
gaps                      Fill the numbering holes
```

**Sanitize messy downloads:**

```
lower                     Clean up all filenames in one shot
lower → undo              Revert if something looks wrong
```

**Batch process a huge folder:**

```
split 4                   Divide into part_1/ ... part_4/
# process each part independently
```

**Clipboard workflow:**

```
cpath                     Copy CWD path for pasting elsewhere
clip README.md            Copy file contents to clipboard
```
