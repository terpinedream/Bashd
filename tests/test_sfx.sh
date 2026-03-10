#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing sfx..."

# ── sfx -d (date suffix) ─────────────────────────────────────────────
begin_test "sfx -d adds date suffix before extension"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" sfx -d >/dev/null 2>&1
today=$(date +%Y_%m_%d)
assert_exists "photo_${today}.jpg" && assert_exists "report_${today}.pdf" && pass
teardown_sandbox

# ── sfx -i (index suffix) ────────────────────────────────────────────
begin_test "sfx -i adds index suffix"
setup_sandbox
touch alpha.txt beta.txt gamma.txt
"$BASHD" sfx -i >/dev/null 2>&1
assert_name_matches '_001\.txt$' && assert_name_matches '_003\.txt$' && pass
teardown_sandbox

# ── sfx -p (parent suffix) ───────────────────────────────────────────
begin_test "sfx -p adds parent dir name suffix"
setup_sandbox
parent=$(basename "$_SANDBOX")
touch hello.txt
"$BASHD" sfx -p >/dev/null 2>&1
assert_exists "hello_${parent}.txt" && pass
teardown_sandbox

# ── sfx + undo round-trip ────────────────────────────────────────────
begin_test "sfx -i then undo restores originals"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" sfx -i >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

# ── sfx --help ────────────────────────────────────────────────────────
begin_test "sfx --help exits 0"
"$BASHD" sfx --help >/dev/null 2>&1
assert_exit_zero $? && pass

print_summary
