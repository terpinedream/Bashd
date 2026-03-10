#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing rmsfx..."

# ── rmsfx default (1 segment) ────────────────────────────────────────
begin_test "rmsfx strips one suffix segment"
setup_sandbox
touch file_suffix.txt doc_tag.pdf
"$BASHD" rmsfx >/dev/null 2>&1
assert_exists "file.txt" && assert_exists "doc.pdf" && pass
teardown_sandbox

# ── rmsfx -n 2 ───────────────────────────────────────────────────────
begin_test "rmsfx -n 2 strips two suffix segments"
setup_sandbox
touch a_b_c.txt x_y_z.pdf
"$BASHD" rmsfx -n 2 >/dev/null 2>&1
assert_exists "a.txt" && assert_exists "x.pdf" && pass
teardown_sandbox

# ── rmsfx -d (date suffix) ───────────────────────────────────────────
begin_test "rmsfx -d strips date suffix"
setup_sandbox
today=$(date +%Y_%m_%d)
touch "photo_${today}.jpg" "report_${today}.pdf"
"$BASHD" rmsfx -d >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

# ── sfx -d then rmsfx -d round-trip ──────────────────────────────────
begin_test "sfx -d then rmsfx -d round-trip"
setup_sandbox
touch photo.jpg report.pdf
"$BASHD" sfx -d >/dev/null 2>&1
"$BASHD" rmsfx -d >/dev/null 2>&1
assert_exists "photo.jpg" && assert_exists "report.pdf" && pass
teardown_sandbox

print_summary
