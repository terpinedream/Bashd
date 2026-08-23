#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing wrap..."

# ── wrap (no args) wraps into auto-named dir ──────────────────────────
begin_test "wrap (no args) moves files into a subdirectory"
setup_sandbox
mkdir only
touch a.txt b.txt c.txt
"$BASHD" wrap >/dev/null 2>&1
assert_exists "only/a.txt" && assert_exists "only/b.txt" && pass
teardown_sandbox

# ── wrap <dir> moves into existing dir ────────────────────────────────
begin_test "wrap <dir> moves files into existing directory"
setup_sandbox
mkdir target
touch a.txt b.txt
"$BASHD" wrap target >/dev/null 2>&1
assert_exists "target/a.txt" && assert_exists "target/b.txt" && pass
teardown_sandbox

# ── wrap -c <name> creates dir and moves ──────────────────────────────
begin_test "wrap -c creates new directory and moves files"
setup_sandbox
touch a.txt b.txt
"$BASHD" wrap -c mydir >/dev/null 2>&1
assert_exists "mydir/a.txt" && assert_exists "mydir/b.txt" && pass
teardown_sandbox

# ── wrap -c -a <name> includes subdirs ────────────────────────────────
begin_test "wrap -c -a moves files and directories"
setup_sandbox
touch a.txt
mkdir subdir
touch subdir/inner.txt
"$BASHD" wrap -c -a bundle >/dev/null 2>&1
assert_exists "bundle/a.txt" && assert_exists "bundle/subdir/inner.txt" && pass
teardown_sandbox

# ── wrap then uwrap round-trip ────────────────────────────────────────
begin_test "wrap -c then uwrap restores original files"
setup_sandbox
touch a.txt b.txt
"$BASHD" wrap -c mydir >/dev/null 2>&1
"$BASHD" uwrap mydir >/dev/null 2>&1
assert_exists "a.txt" && assert_exists "b.txt" && assert_not_exists "mydir" && pass
teardown_sandbox

print_summary
