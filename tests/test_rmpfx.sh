#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing rmpfx..."

# ── rmpfx default (1 segment) ────────────────────────────────────────
begin_test "rmpfx strips one prefix segment"
setup_sandbox
touch prefix_file.txt another_doc.pdf
"$BASHD" rmpfx >/dev/null 2>&1
assert_exists "file.txt" && assert_exists "doc.pdf" && pass
teardown_sandbox

# ── rmpfx -n 2 ───────────────────────────────────────────────────────
begin_test "rmpfx -n 2 strips two prefix segments"
setup_sandbox
touch a_b_c.txt x_y_z.pdf
"$BASHD" rmpfx -n 2 >/dev/null 2>&1
assert_exists "c.txt" && assert_exists "z.pdf" && pass
teardown_sandbox

# ── rmpfx -d (date prefix) ───────────────────────────────────────────
begin_test "rmpfx -d strips date prefix"
setup_sandbox
today=$(date +%Y_%m_%d)
touch "${today}_photo.jpg" "${today}_report.pdf"
"$BASHD" rmpfx -d >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

# ── rmpfx + undo round-trip ──────────────────────────────────────────
begin_test "rmpfx then undo restores originals"
setup_sandbox
touch prefix_file.txt
"$BASHD" rmpfx >/dev/null 2>&1
assert_exists "file.txt"
"$BASHD" undo >/dev/null 2>&1
assert_exists "prefix_file.txt" && pass
teardown_sandbox

# ── pfx -d then rmpfx -d round-trip ──────────────────────────────────
begin_test "pfx -d then rmpfx -d round-trip"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" pfx -d >/dev/null 2>&1
"$BASHD" rmpfx -d >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

print_summary
