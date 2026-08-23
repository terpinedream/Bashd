#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing uwrap..."

# ── uwrap unpacks all dirs, keeps original names ──────────────────────
begin_test "uwrap unpacks all subdirectories into CWD"
setup_sandbox
mkdir dir1 dir2
touch dir1/a.txt dir2/b.txt
"$BASHD" uwrap >/dev/null 2>&1
assert_exists "a.txt" && assert_exists "b.txt" && assert_not_exists "dir1" && assert_not_exists "dir2" && pass
teardown_sandbox

# ── uwrap single dir ─────────────────────────────────────────────────
begin_test "uwrap <dir> unpacks a specific directory"
setup_sandbox
mkdir dir1 dir2
touch dir1/a.txt dir2/b.txt
"$BASHD" uwrap dir1 >/dev/null 2>&1
assert_exists "a.txt" && assert_exists "dir2" && assert_not_exists "dir1" && pass
teardown_sandbox

# ── wrap then uwrap round-trip ────────────────────────────────────────
begin_test "wrap then uwrap restores original names"
setup_sandbox
touch report.pdf notes.txt data.csv
"$BASHD" wrap -c project >/dev/null 2>&1
assert_exists "project/report.pdf"
"$BASHD" uwrap project >/dev/null 2>&1
assert_exists "report.pdf" && assert_exists "notes.txt" && assert_exists "data.csv"
assert_not_exists "project" && assert_not_exists "project_report.pdf" && pass
teardown_sandbox

# ── collision: keep names, disambiguate with _n ───────────────────────
begin_test "uwrap disambiguates colliding names with _n"
setup_sandbox
mkdir a b
touch a/file.txt b/file.txt
"$BASHD" uwrap >/dev/null 2>&1
assert_exists "file.txt"
# second file should be file_2.txt
assert_exists "file_2.txt" && pass
teardown_sandbox

# ── -p prefixes with directory name ───────────────────────────────────
begin_test "uwrap -p prefixes filenames with source dir name"
setup_sandbox
mkdir photos
touch photos/IMG_001.jpg
"$BASHD" uwrap -p photos >/dev/null 2>&1
assert_exists "photos_IMG_001.jpg" && assert_not_exists "IMG_001.jpg" && pass
teardown_sandbox

# ── path-prefix: sibling dir is not treated as inside CWD ─────────────
begin_test "uwrap does not treat a path-prefix sibling as inside CWD"
setup_sandbox
parent=$(pwd)
mkdir proj proj-backup
touch proj-backup/secret.txt
cd proj
"$BASHD" uwrap "$parent/proj-backup" >/dev/null 2>&1
# Outside CWD → copy, source dir must still exist
assert_exists "$parent/proj-backup/secret.txt"
assert_exists "secret.txt"
cd "$parent"
teardown_sandbox
pass

print_summary
