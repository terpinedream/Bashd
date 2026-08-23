# Project Notes

## What Bashd Is

Bashd is not a collection of unrelated shell aliases. It's a unified toolkit where scripts are designed to work together as composable building blocks for common file operations.

The rename pipeline is the clearest example: `pfx`, `sfx`, `rmpfx`, `rmsfx`, `recase`, `gaps`, `lower`, and `namechange` all share a common logging system (`_bashd_log`) that feeds into `undo`. Every rename script uses the same two-phase rename pattern to prevent filename collisions during batch operations. These aren't independent utilities that happen to live in the same repo -- they were built to chain:

```
namechange "doc.txt" -> nest -> flatten -> rmpfx    # round-trip
pfx -d -i -> undo                                    # safe experimentation
lower -> recase -k                                    # sanitize then normalize
```

The file organization scripts follow the same philosophy. `wrap`/`uwrap`, `nest`/`flatten`, `pfx`/`rmpfx`, `sfx`/`rmsfx`, `bak`/`ubak` are all intentional inverse pairs -- what one script does, the other reverses. `split` distributes files, `wrap` collects them. `byext` and `bydate` sort, `flatten` undoes nesting.

The toolkit targets a specific workflow: you have a directory of files and you need to rename, reorganize, or clean them up quickly from the command line without writing throwaway scripts or remembering `find -exec` incantations. Every script is pure bash with no dependencies beyond standard coreutils.

## What Makes It Useful

**Composability.** Scripts feed into each other by design. The rename pipeline + undo system is genuinely cohesive and not something you get from installing individual tools.

**Two-phase renames.** Batch rename operations first move files to temporary names, then to final names. This prevents the classic collision problem where `a -> b` fails because `b` already exists as another file being renamed.

**Safety defaults.** Destructive operations (`trim`, `qc`, `crush`) always confirm before acting. Rename operations all support `undo`. `tmpws` cleans up on exit. `bak`/`ubak` handle identical file detection intelligently.

**Zero dependencies.** Everything is bash + coreutils. No Python, Perl, Rust, Go, or npm. Run `make install-core` and they work. This matters for minimal servers, containers, and air-gapped environments.

**Consistent interface.** Scripts follow the same conventions: `getopts` for flags, two-phase renames where applicable, same file iteration patterns, same output style (checkmark on success, X on failure, stderr for errors).

## Warnings

### cpt (Copy Last Command Output)

`cpt` works by **re-executing the last command** from your shell history and capturing its output. This is the only portable way to achieve this in bash without invasive session-wide output capturing.

**This means the command runs again.** If your last command was `rm -rf something`, `curl -X POST`, a database mutation, or anything with side effects, `cpt` will execute it a second time. The script shows you the command and asks for confirmation before re-running, but the `-y` flag bypasses this.

Use `cpt` for safe, read-only commands: `ls`, `grep`, `cat`, `find`, `git status`, `df`, etc. Do not use it blindly after destructive or stateful commands.

I intend to find a safer approach to this -- ideally one that captures output passively without re-execution. The challenge is that bash doesn't provide a clean hook for intercepting command output without wrapping the entire session in `script` or `tee`, both of which break interactive programs. If you know a better method, I'd welcome a PR or issue.

### Scripts That Move/Delete Files

`crush`, `flatten`, `wrap`, `uwrap`, `trim`, `qc`, and the rename scripts all modify the filesystem. `crush` refuses to run in `/` or `$HOME`. `trim` and `qc` confirm before deleting; `trim` also has `-n` for dry run. Rename operations support `undo`. Organization movers (`wrap`, `nest`, `byext`, …) do not yet prompt. Always test on a scratch directory first -- `tmpws -c` exists for exactly this purpose.

### bashd-init.sh

Sourcing `bashd-init.sh` modifies your shell environment: it appends to `PROMPT_COMMAND`, sets EXIT traps, and defines wrapper functions for ~10 scripts. This is necessary for directory-changing scripts to work (a subprocess can't `cd` the parent shell), but it does mean Bashd has a non-trivial shell footprint. If something in your shell breaks after sourcing it, `bashd-init.sh` is a reasonable suspect.

## Room for Improvement

**Testing.** The automated test suite covers the rename pipeline and organization scripts (65+ assertions across 17 test files), but helpers, extras, and interactive scripts aren't tested yet. Expanding coverage to navigation scripts and edge cases would increase confidence further.

**Installation.** The Makefile provides `install-core`, `install-extra`, `install-all`, and `uninstall` targets. The AUR package (the `aur` branch) is a parallel Arch-flavored install of the same scripts (profile.d, `/usr/share/bashd`), not a second codebase.

**Overlap with existing tools.** Some scripts cover ground already served by established tools (`zoxide` for navigation, Perl `rename` for batch renaming, `fdupes` for deduplication, `ncdu`/`dust` for disk usage). Bashd's value isn't that these scripts are better than dedicated alternatives in isolation -- it's that they're a single, consistent, dependency-free set that work together. But I recognize the overlap exists, and users who already have those tools installed may find parts of the toolkit redundant. The new project structure aims to address this exact issue by organizing scripts into categories.

**Scope.** Scripts are now categorized into core (30 essential rename/organize/clipboard/cleanup tools), helpers (9 cd-requiring navigation tools), and extra (10 niche/system utilities). The `bashd` dispatcher provides a single entry point, and the config-driven alias system lets users control which commands they want available without the prefix.
