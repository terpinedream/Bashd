#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing namechange..."

# ── namechange basic ──────────────────────────────────────────────────
begin_test "namechange renames files to template"
setup_sandbox
touch a.txt b.txt c.txt
"$BASHD" namechange "file.txt" >/dev/null 2>&1
assert_file_count 3 . && assert_name_matches "file" && pass
teardown_sandbox

# ── namechange + undo ─────────────────────────────────────────────────
begin_test "namechange then undo restores originals"
setup_sandbox
touch alpha.txt beta.txt
"$BASHD" namechange "doc.txt" >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "alpha.txt" && assert_exists "beta.txt" && pass
teardown_sandbox

print_summary
