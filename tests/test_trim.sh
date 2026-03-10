#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing trim..."

# ── trim removes zero-byte files ──────────────────────────────────────
begin_test "trim removes zero-byte files"
setup_sandbox
touch empty.txt
echo "content" > real.txt
echo "y" | "$BASHD" trim >/dev/null 2>&1
assert_not_exists "empty.txt" && assert_exists "real.txt" && pass
teardown_sandbox

# ── trim removes .DS_Store ────────────────────────────────────────────
begin_test "trim removes .DS_Store"
setup_sandbox
echo "data" > .DS_Store
echo "content" > real.txt
echo "y" | "$BASHD" trim >/dev/null 2>&1
assert_not_exists ".DS_Store" && assert_exists "real.txt" && pass
teardown_sandbox

# ── trim removes empty dirs ───────────────────────────────────────────
begin_test "trim removes empty directories"
setup_sandbox
mkdir emptydir
echo "content" > real.txt
echo "y" | "$BASHD" trim >/dev/null 2>&1
assert_not_exists "emptydir" && assert_exists "real.txt" && pass
teardown_sandbox

# ── trim -n dry run ───────────────────────────────────────────────────
begin_test "trim -n dry run does not delete"
setup_sandbox
touch empty.txt
mkdir emptydir
"$BASHD" trim -n >/dev/null 2>&1
assert_exists "empty.txt" && assert_exists "emptydir" && pass
teardown_sandbox

print_summary
