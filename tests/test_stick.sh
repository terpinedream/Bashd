#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing stick..."

# ── stick basic ───────────────────────────────────────────────────────
begin_test "stick creates dir and moves matching files"
setup_sandbox
touch "photos_1.jpg" "photos_2.jpg" "readme.txt"
"$BASHD" stick photos >/dev/null 2>&1
assert_exists "photos/photos_1.jpg" && assert_exists "photos/photos_2.jpg" && assert_exists "readme.txt" && pass
teardown_sandbox

# ── stick -i (case insensitive) ──────────────────────────────────────
begin_test "stick -i matches case-insensitively"
setup_sandbox
touch "Photos_1.jpg" "PHOTOS_2.jpg" "readme.txt"
"$BASHD" stick -i photos >/dev/null 2>&1
assert_exists "photos/Photos_1.jpg" && assert_exists "photos/PHOTOS_2.jpg" && pass
teardown_sandbox

# ── stick -w (whole word) ────────────────────────────────────────────
begin_test "stick -w matches whole word only"
setup_sandbox
touch "photo.jpg" "photos_1.jpg" "photograph.jpg"
"$BASHD" stick -w photo >/dev/null 2>&1
assert_exists "photo/photo.jpg" && assert_exists "photos_1.jpg" && assert_exists "photograph.jpg" && pass
teardown_sandbox

print_summary
