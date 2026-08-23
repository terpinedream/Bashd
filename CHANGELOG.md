# Changelog

## v2.0.1 — Fix and harden existing scripts

Same 49 commands, no new tools. This release makes inverse pairs, docs, and safety match the code.

### Breaking changes

- **`uwrap` keeps original names.** `photos/IMG_001.jpg` unpacks as `IMG_001.jpg`, not `photos_IMG_001.jpg`. Use `uwrap -p` for the old prefix-everything behavior. `wrap` / `stick` / `split` now round-trip through `uwrap`.
- **`nest` no longer writes a leading delimiter on the inner name.** `photo_beach.jpg` becomes `photo/beach.jpg`, not `photo/_beach.jpg`. `flatten` still joins with `_`.
- **`archive` / `pullfrom` / `pushto` no longer hardcode a remote host.** Set `REMOTE_HOST` (and `ARCHIVE_BASE` for archive) in `~/.config/bashd/remote.conf`, or `BASHD_REMOTE` / `BASHD_ARCHIVE_BASE` in the environment.

### Behavior

- **Dry-run (`-n`)** on `wrap`, `uwrap`, `nest`, `flatten`, `stick`, `split`, `byext`, `bydate`.
- **HOME/root guards** on bulk movers and `qc` (same refusal as `crush`).
- **Optional file args** on `pfx` / `sfx` / `recase` / `lower` (`pfx -d *.jpg`); default is still all loose files.
- **`clip` reads stdin** when there is no filename and stdin is a pipe (`ls | clip`). Prefer that over `cpt` when you already have the output.
- **Rename family skips leading-dot files** (`.bashrc`). `.tar.gz` is still split on the last suffix.
- **Shared libraries:** `_bashd_files` (loose-file iteration, HOME/root), `_bashd_clip` (clipboard copy/paste), `_bashd_remote` (remote extras config).
- **Dispatcher** finds scripts via `BASHD_ROOT`, then `core/` beside itself, then `/usr/share/bashd/core` (AUR layout). `bashd alias` emits init-matching wrappers for `bm` / `mark` / `tmpws` / `qs`.
- **AUR packaging** lives on the `aur` branch (`PKGBUILD`, `.SRCINFO`), not on main. Arch install uses `/usr/share/bashd`, `profile.d`, PATH wrappers, and `prefix`/`bfold`/`cram`/`ufold` shims. It is not `make install`.

### Bug fixes

- `uwrap` path-prefix check treated `/home/u/proj-backup` as inside `/home/u/proj`.
- `--help` exits 0 and invalid usage exits 1 (`qc`, `gaps`, `stick`, `clip`, `byext`, `split`, `pfx`, and others).
- `tmpws` no longer overwrites the init EXIT trap (mark/lastcmd cleanup).
- CD wrappers: `crush` / `ld` pass `"$@"`; `qs --help` is not swallowed. Helper help stays on stderr.
- `bydate` uses GNU `date -r` instead of Perl.
- `pull` refuses destination collisions like `bring`.
- `dedupe -r` skips `_dupes/` when hashing.
- `sized -d -r` no longer breaks on directory names with spaces.
- `recase` rejects multiple flags (docs already said exactly one).
- `pfx` / `sfx` collision-check pending temp names (same as `rmpfx` / `rmsfx`).
- `clipd` preserves trailing newlines.
- Errors from `pull`, `uwrap`, `namechange` go to stderr.
- Docs match code for `namechange` (`1_file.txt`), `pfx -d -i` / `-p`/`-i` prepend, `ubak` (no prompt), bring vs pull, `dotsync` PATHS, `archive -e`, `tmpws -r`.

### Tests

- 18 test files (was 17). Coverage now includes wrap → uwrap names, nest inner names, nest → flatten, `--help` exit 0, pull collision, recase exclusive flags, bydate without Perl, `bring`, `byext`, wrap `-n`, and `pfx` file args.

## v2.0.0 — Project Overhaul

This is a major restructure of the toolkit. If you were using Bashd before, read this before updating.

### What changed and why

The project grew from a handful of scripts to 49 commands. Dumping all of them into `/usr/bin` as loose files wasn't scaling — it cluttered the system namespace, made installation/uninstallation manual, and there was no way to tell which files on your system belonged to Bashd. This release fixes that with a single entry point, proper installation, and automated tests.

### Breaking changes

- **Scripts are no longer installed as individual files on PATH.** All commands now go through the `bashd` dispatcher (e.g. `bashd pfx -d`). With `bashd-init.sh` sourced, aliased commands still work bare (`pfx -d`) — but the underlying mechanism changed.
- **Scripts moved into subdirectories.** `scripts/` is now split into `scripts/core/`, `scripts/helpers/`, and `scripts/extra/`. If you had scripts symlinked or referenced by absolute path, those paths broke.
- **Renamed scripts (from previous release).** `prefix` -> `pfx`, `suffix` -> `sfx`, `ufold` -> `uwrap`, `fold`+`cram` -> `wrap`, `trim`+`empt` -> `trim` (with `-n` dry run flag).
- **`bashd-init.sh` rewritten.** The init file now routes everything through the dispatcher and reads alias config from `~/.config/bashd/aliases.conf`. If you sourced the old init file, re-source after updating.
- **Old manual install needs cleanup.** If you had scripts in `/usr/bin`, remove them before installing (`bashd` won't conflict, but stale copies of `pfx`, `hop`, etc. will shadow the dispatcher aliases). See the README for a cleanup command.

### New features

**Single entry point (`bashd` dispatcher)**
- `bashd <command> [args]` runs any command
- `bashd --help <command>` shows detailed help
- `bashd --chart` prints the ASCII command chart
- `bashd --list [core|helpers|extra]` lists available commands
- `bashd alias [--default]` manages alias configuration

**Config-driven aliases (`~/.config/bashd/aliases.conf`)**
- Control which commands can be run without the `bashd` prefix
- One command per line, comments supported
- If the file doesn't exist, all core + helper commands are aliased by default (backward compatible)
- Run `bashd alias --default` to generate the config file

**Script categorization**
- **Core** (30 scripts): rename, organize, clipboard, cleanup — the main toolkit value
- **Helpers** (9 scripts): cd-requiring navigation (`hop`, `crush`, `ld`, etc.)
- **Extra** (10 scripts): niche/system-specific (`cleanme`, `paclock`, `dotsync`, etc.)

**Consistent `--help` on every script**
- All 49 scripts now handle `-h` and `--help`
- Help exits 0, invalid usage exits 1

**Automated test suite**
- 17 test files covering the rename pipeline and organization scripts
- 65+ assertions testing `pfx`, `sfx`, `rmpfx`, `rmsfx`, `recase`, `lower`, `gaps`, `namechange`, `undo`, `wrap`, `uwrap`, `nest`, `flatten`, `split`, `stick`, `trim`, `bak`/`ubak`, `dedupe`
- Run with `make test`

**Makefile**
- `make test` — run the test suite
- `make install-core` — install dispatcher + core + helpers
- `make install-extra` — install extra scripts
- `make install-all` — install everything
- `make uninstall` — clean removal

### Bug fixes

- `dedupe` wasn't finding duplicates due to missing `-print0` in `find` command
- `trim` wasn't accepting piped confirmation (`y`) due to whitespace in reply parsing
- `trim` skipped `.DS_Store` files that had content (logic ordering fix)

### Migration guide

1. Remove old scripts from `/usr/bin` (see README for the safe removal command)
2. Pull the latest and run `sudo make install-core` (or `install-all`)
3. Update your shell rc to source the new init file:
   ```bash
   source /usr/local/bin/bashd-scripts/bashd-init.sh
   ```
4. Optionally generate an alias config: `bashd alias --default`
5. Restart your shell
