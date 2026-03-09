# Contributing to Bashd

PRs and issues are welcome. Here are a few guidelines to keep things consistent.

## Philosophy

- **Small and focused** -- each script does one thing well
- **No dependencies** beyond standard coreutils (awk, sed, find, etc.)
- **Safe by default** -- destructive operations should confirm first or offer a dry run
- **Portable** -- target bash 4+ on Linux; avoid bashisms that break across distros

## Adding a new script

1. Put it in `scripts/`
2. Make it executable (`chmod +x`)
3. Add a brief header comment explaining what it does and its usage
4. Add an entry to `scripts/bashd` (both `get_full_desc` and the chart)
5. Add a row to the table in `README.md`
6. If it renames files, integrate `_bashd_log` so `undo` works

## Code style

- Use the same patterns as existing scripts (file iteration, two-phase rename, collision handling)
- Print `✓` on success, `✗` on failure
- Send errors to stderr (`>&2`)
- No comments that just narrate what the code does

## Testing

Try your script on a throwaway directory (`test_sandbox/` is gitignored for this purpose) before submitting.
