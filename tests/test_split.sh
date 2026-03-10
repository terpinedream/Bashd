#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing split..."

# ── split N distributes files ─────────────────────────────────────────
begin_test "split 3 creates 3 part directories"
setup_sandbox
touch a.txt b.txt c.txt d.txt e.txt f.txt
"$BASHD" split 3 >/dev/null 2>&1
assert_exists "part_1" && assert_exists "part_2" && assert_exists "part_3" && pass
teardown_sandbox

# ── split distributes all files ───────────────────────────────────────
begin_test "split distributes all files into parts"
setup_sandbox
touch a.txt b.txt c.txt d.txt e.txt f.txt
"$BASHD" split 2 >/dev/null 2>&1
count1=$(find part_1 -type f | wc -l)
count2=$(find part_2 -type f | wc -l)
total=$((count1 + count2))
assert_equals "6" "$total" && pass
teardown_sandbox

# ── split refuses if part_* exists ────────────────────────────────────
begin_test "split refuses if part_* dirs already exist"
setup_sandbox
touch a.txt b.txt
mkdir part_1
"$BASHD" split 2 >/dev/null 2>&1
rc=$?
assert_exit_nonzero "$rc" && pass
teardown_sandbox

print_summary
