#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing uwrap..."

# ── uwrap unpacks all dirs ────────────────────────────────────────────
begin_test "uwrap unpacks all subdirectories into CWD"
setup_sandbox
mkdir dir1 dir2
touch dir1/a.txt dir2/b.txt
"$BASHD" uwrap >/dev/null 2>&1
assert_file_count 2 . && pass
teardown_sandbox

# ── uwrap single dir ─────────────────────────────────────────────────
begin_test "uwrap <dir> unpacks a specific directory"
setup_sandbox
mkdir dir1 dir2
touch dir1/a.txt dir2/b.txt
"$BASHD" uwrap dir1 >/dev/null 2>&1
assert_exists "dir2" && pass
teardown_sandbox

print_summary
