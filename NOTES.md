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

**Zero dependencies.** Everything is bash + coreutils. No Python, Perl, Rust, Go, or npm. Copy the scripts to `/usr/local/bin` and they work. This matters for minimal servers, containers, and air-gapped environments.

**Consistent interface.** Scripts follow the same conventions: `getopts` for flags, two-phase renames where applicable, same file iteration patterns, same output style (checkmark on success, X on failure, stderr for errors).

## Warnings

### cpt (Copy Last Command Output)

`cpt` works by **re-executing the last command** from your shell history and capturing its output. This is the only portable way to achieve this in bash without invasive session-wide output capturing.

**This means the command runs again.** If your last command was `rm -rf something`, `curl -X POST`, a database mutation, or anything with side effects, `cpt` will execute it a second time. The script shows you the command and asks for confirmation before re-running, but the `-y` flag bypasses this.

Use `cpt` for safe, read-only commands: `ls`, `grep`, `cat`, `find`, `git status`, `df`, etc. Do not use it blindly after destructive or stateful commands.

I intend to find a safer approach to this -- ideally one that captures output passively without re-execution. The challenge is that bash doesn't provide a clean hook for intercepting command output without wrapping the entire session in `script` or `tee`, both of which break interactive programs. If you know a better method, I'd welcome a PR or issue.

### Scripts That Move/Delete Files

`crush`, `flatten`, `wrap`, `uwrap`, `trim`, `qc`, and the rename scripts all modify the filesystem. They include safety measures (confirmation prompts, path guards against running in `/` or `$HOME`, dry-run flags), but they are not bulletproof. Always test on a scratch directory first -- `tmpws -c` exists for exactly this purpose.

### bashd-init.sh

Sourcing `bashd-init.sh` modifies your shell environment: it appends to `PROMPT_COMMAND`, sets EXIT traps, and defines wrapper functions for ~10 scripts. This is necessary for directory-changing scripts to work (a subprocess can't `cd` the parent shell), but it does mean Bashd has a non-trivial shell footprint. If something in your shell breaks after sourcing it, `bashd-init.sh` is a reasonable suspect.

## Room for Improvement

**Testing.** There is no automated test suite. For a toolkit that batch-renames and deletes files, this is a real gap. Integration tests using temp directories would go a long way toward confidence.

**Installation.** The setup story is manual. A `Makefile` with `install`/`uninstall` targets, or packaging for AUR/Homebrew/Nix, would lower the barrier significantly. The AUR package hasn't been updated in awhile, but will be after some more safeguards are put in place. 

**Overlap with existing tools.** Some scripts cover ground already served by established tools (`zoxide` for navigation, Perl `rename` for batch renaming, `fdupes` for deduplication, `ncdu`/`dust` for disk usage). Bashd's value isn't that these scripts are better than dedicated alternatives in isolation -- it's that they're a single, consistent, dependency-free set that work together. But I recognize the overlap exists, and users who already have those tools installed may find parts of the toolkit redundant.

**Scope.** The toolkit has grown beyond the original "handful of helpers" scope. Not every script is equally essential. The core strength is the rename/organize pipeline; some of the peripheral scripts are more situational. Future branches for different sets of scripts grouped by functionality are on my radar if there is interest. 
