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
begin_test "nest then flatten restores original names"
setup_sandbox
touch "photos_sunset.jpg" "photos_beach.jpg"
"$BASHD" nest >/dev/null 2>&1
assert_exists "photos/sunset.jpg"
"$BASHD" flatten >/dev/null 2>&1
assert_exists "photos_sunset.jpg" && assert_exists "photos_beach.jpg"
assert_not_exists "photos" && pass
teardown_sandbox

print_summary
