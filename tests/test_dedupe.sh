#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing dedupe..."

# ── dedupe finds duplicates ───────────────────────────────────────────
begin_test "dedupe moves duplicate files to _dupes/"
setup_sandbox
echo "same content" > file1.txt
echo "same content" > file2.txt
echo "different" > file3.txt
"$BASHD" dedupe >/dev/null 2>&1
assert_exists "_dupes" && assert_exists "file3.txt" && pass
teardown_sandbox

# ── dedupe keeps first, moves rest ────────────────────────────────────
begin_test "dedupe keeps one copy, moves duplicates"
setup_sandbox
echo "same" > a.txt
echo "same" > b.txt
echo "same" > c.txt
"$BASHD" dedupe >/dev/null 2>&1
dupe_count=$(find _dupes -type f | wc -l)
dupe_count="${dupe_count// /}"
assert_equals "2" "$dupe_count" && pass
teardown_sandbox

# ── dedupe no dupes ───────────────────────────────────────────────────
begin_test "dedupe with no duplicates creates no _dupes dir"
setup_sandbox
echo "unique1" > a.txt
echo "unique2" > b.txt
"$BASHD" dedupe >/dev/null 2>&1
assert_not_exists "_dupes" && pass
teardown_sandbox

print_summary
