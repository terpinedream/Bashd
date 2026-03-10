#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing lower..."

# ── lower basic ───────────────────────────────────────────────────────
begin_test "lower sanitizes filenames to lowercase"
setup_sandbox
touch "Hello World.TXT"
"$BASHD" lower >/dev/null 2>&1
assert_exists "hello_world.txt" && pass
teardown_sandbox

# ── lower special characters ─────────────────────────────────────────
begin_test "lower replaces special chars with underscores"
setup_sandbox
touch "My File (Copy) [2].jpg"
"$BASHD" lower >/dev/null 2>&1
assert_exists "my_file_copy_2.jpg" && pass
teardown_sandbox

# ── lower already-clean files ─────────────────────────────────────────
begin_test "lower skips already-clean filenames"
setup_sandbox
touch "clean_file.txt"
"$BASHD" lower >/dev/null 2>&1
assert_exists "clean_file.txt" && pass
teardown_sandbox

# ── lower + undo ──────────────────────────────────────────────────────
begin_test "lower then undo restores originals"
setup_sandbox
touch "Hello World.TXT"
"$BASHD" lower >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "Hello World.TXT" && pass
teardown_sandbox

print_summary
