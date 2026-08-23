#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing nest..."

# ── nest default delimiter ────────────────────────────────────────────
begin_test "nest creates subdirs from prefix (default _ delimiter)"
setup_sandbox
touch "photos_sunset.jpg" "photos_beach.jpg" "readme.txt"
"$BASHD" nest >/dev/null 2>&1
assert_exists "photos" && assert_exists "readme.txt" && pass
teardown_sandbox

# ── nest inner filenames have no leading delimiter ────────────────────
begin_test "nest writes rest of filename without leading delimiter"
setup_sandbox
touch "photos_sunset.jpg" "photos_beach.jpg"
"$BASHD" nest >/dev/null 2>&1
assert_exists "photos/sunset.jpg" && assert_exists "photos/beach.jpg"
assert_not_exists "photos/_sunset.jpg" && pass
teardown_sandbox

# ── nest custom delimiter ─────────────────────────────────────────────
begin_test "nest with custom delimiter"
setup_sandbox
touch "photos-sunset.jpg" "photos-beach.jpg"
"$BASHD" nest - >/dev/null 2>&1
assert_exists "photos" && assert_exists "photos/sunset.jpg" && pass
teardown_sandbox

# ── nest skips files without delimiter ─────────────────────────────────
begin_test "nest leaves files without delimiter untouched"
setup_sandbox
touch "readme.txt" "notes_meeting.txt"
"$BASHD" nest >/dev/null 2>&1
assert_exists "readme.txt" && assert_exists "notes" && assert_exists "notes/meeting.txt" && pass
teardown_sandbox

print_summary
