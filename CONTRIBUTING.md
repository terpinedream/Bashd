# Contributing to Bashd

PRs and issues are welcome. Here are a few guidelines to keep things consistent.

## Philosophy

- **Small and focused** -- each script does one thing well
- **No dependencies** beyond standard coreutils (awk, sed, find, etc.)
- **Safe by default** -- destructive operations should confirm first or offer a dry run
- **Portable** -- target bash 4+ on Linux; avoid bashisms that break across distros

## Adding a new script

1. Put it in the appropriate category:
   - `scripts/core/` for rename, organize, clipboard, or cleanup tools
   - `scripts/helpers/` for cd-requiring navigation scripts
   - `scripts/extra/` for niche, system-specific, or personal utilities
2. Make it executable (`chmod +x`)
3. Add a brief header comment explaining what it does and its usage
4. Add a `usage()` function and handle `-h`/`--help` (exit 0 on help, exit 1 on error)
5. Add an entry to `scripts/bashd` (both `get_full_desc`, the chart, and the appropriate command list)
6. Add a row to the table in `README.md`
7. If it renames files, integrate `_bashd_log` so `undo` works (source via `$(dirname "$(readlink -f "$0")")/../_bashd_log`)
8. Add tests in `tests/test_<name>.sh` using the helpers in `tests/test_helpers.sh`

## Code style

- Use the same patterns as existing scripts (file iteration, two-phase rename, collision handling)
- Print `✓` on success, `✗` on failure
- Send errors to stderr (`>&2`)
- No comments that just narrate what the code does

## Testing

Run the test suite before submitting:

```bash
make test
```

You can also test manually on a throwaway directory (`test_sandbox/` is gitignored for this purpose, or use `tmpws -c`).
