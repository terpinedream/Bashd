#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing pfx..."

# ── pfx -d (date prefix) ─────────────────────────────────────────────
begin_test "pfx -d adds date prefix"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" pfx -d >/dev/null 2>&1
today=$(date +%Y_%m_%d)
assert_exists "${today}_photo.jpg" && assert_exists "${today}_report.pdf" && pass
teardown_sandbox

# ── pfx -i (index prefix) ────────────────────────────────────────────
begin_test "pfx -i adds index prefix"
setup_sandbox
touch alpha.txt beta.txt gamma.txt
"$BASHD" pfx -i >/dev/null 2>&1
assert_name_matches '^001_' && assert_name_matches '^003_' && pass
teardown_sandbox

# ── pfx -p (parent prefix) ───────────────────────────────────────────
begin_test "pfx -p adds parent dir name prefix"
setup_sandbox
parent=$(basename "$_SANDBOX")
touch hello.txt
"$BASHD" pfx -p >/dev/null 2>&1
assert_exists "${parent}_hello.txt" && pass
teardown_sandbox

# ── pfx combined flags ───────────────────────────────────────────────
begin_test "pfx -d -i combines date and index"
setup_sandbox
touch a.txt b.txt
"$BASHD" pfx -d -i >/dev/null 2>&1
today=$(date +%Y_%m_%d)
assert_name_matches "^${today}_001_" && pass
teardown_sandbox

# ── pfx + undo round-trip ────────────────────────────────────────────
begin_test "pfx -d then undo restores originals"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" pfx -d >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

# ── pfx --help ────────────────────────────────────────────────────────
begin_test "pfx --help exits 0"
"$BASHD" pfx --help >/dev/null 2>&1
assert_exit_zero $? && pass

print_summary
