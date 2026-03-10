#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing flatten..."

# ── flatten basic ─────────────────────────────────────────────────────
begin_test "flatten moves subdir files to CWD with path prefix"
setup_sandbox
mkdir -p a/b
touch a/file1.txt a/b/file2.txt
"$BASHD" flatten >/dev/null 2>&1
assert_exists "a_file1.txt" && assert_exists "a_b_file2.txt" && pass
teardown_sandbox

# ── nest + flatten round-trip ─────────────────────────────────────────
begin_test "nest then flatten produces files in CWD"
setup_sandbox
touch "photos_sunset.jpg" "photos_beach.jpg"
"$BASHD" nest >/dev/null 2>&1
assert_exists "photos"
"$BASHD" flatten >/dev/null 2>&1
count=$(find . -maxdepth 1 -type f | wc -l)
count="${count// /}"
assert_equals "2" "$count" && pass
teardown_sandbox

print_summary
