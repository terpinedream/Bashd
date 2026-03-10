#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing gaps..."

# ── gaps fills numbering gaps ─────────────────────────────────────────
begin_test "gaps re-indexes to fill gaps"
setup_sandbox
touch "hello_01.txt" "hello_03.txt" "hello_05.txt"
"$BASHD" gaps >/dev/null 2>&1
assert_exists "hello_01.txt" && assert_exists "hello_02.txt" && assert_exists "hello_03.txt" && pass
teardown_sandbox

# ── gaps skips non-numbered files ─────────────────────────────────────
begin_test "gaps skips files without numbers"
setup_sandbox
touch "test.txt" "hello_01.txt" "hello_03.txt"
"$BASHD" gaps >/dev/null 2>&1
assert_exists "test.txt" && assert_exists "hello_01.txt" && assert_exists "hello_02.txt" && pass
teardown_sandbox

# ── gaps preserves padding ────────────────────────────────────────────
begin_test "gaps preserves padding width"
setup_sandbox
touch "file_001.txt" "file_003.txt" "file_005.txt"
"$BASHD" gaps >/dev/null 2>&1
assert_exists "file_001.txt" && assert_exists "file_002.txt" && assert_exists "file_003.txt" && pass
teardown_sandbox

# ── gaps + undo ───────────────────────────────────────────────────────
begin_test "gaps then undo restores originals"
setup_sandbox
touch "item_01.txt" "item_03.txt"
"$BASHD" gaps >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "item_01.txt" && assert_exists "item_03.txt" && pass
teardown_sandbox

print_summary
