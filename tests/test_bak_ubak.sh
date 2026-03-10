#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing bak + ubak..."

# ── bak creates backup ───────────────────────────────────────────────
begin_test "bak creates .bak copy"
setup_sandbox
echo "hello" > test.txt
"$BASHD" bak test.txt >/dev/null 2>&1
assert_exists "test.txt.bak" && assert_exists "test.txt" && pass
teardown_sandbox

# ── ubak restores identical backup ────────────────────────────────────
begin_test "ubak removes .bak if identical to original"
setup_sandbox
echo "hello" > test.txt
"$BASHD" bak test.txt >/dev/null 2>&1
"$BASHD" ubak >/dev/null 2>&1
assert_not_exists "test.txt.bak" && assert_exists "test.txt" && pass
teardown_sandbox

# ── ubak -r reverts to backup ─────────────────────────────────────────
begin_test "ubak -r reverts original to backup contents"
setup_sandbox
echo "original" > test.txt
"$BASHD" bak test.txt >/dev/null 2>&1
echo "modified" > test.txt
"$BASHD" ubak -r test.txt.bak >/dev/null 2>&1
content=$(cat test.txt)
assert_equals "original" "$content" && pass
teardown_sandbox

# ── ubak -k keeps original, discards bak ──────────────────────────────
begin_test "ubak -k keeps original, removes backup"
setup_sandbox
echo "original" > test.txt
"$BASHD" bak test.txt >/dev/null 2>&1
echo "modified" > test.txt
"$BASHD" ubak -k test.txt.bak >/dev/null 2>&1
assert_not_exists "test.txt.bak"
content=$(cat test.txt)
assert_equals "modified" "$content" && pass
teardown_sandbox

# ── bak * backs up all files ──────────────────────────────────────────
begin_test "bak * backs up all files in CWD"
setup_sandbox
echo "a" > a.txt
echo "b" > b.txt
"$BASHD" bak a.txt b.txt >/dev/null 2>&1
assert_exists "a.txt.bak" && assert_exists "b.txt.bak" && pass
teardown_sandbox

print_summary
