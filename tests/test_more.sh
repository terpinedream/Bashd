#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing extra core behaviors..."

# ── wrap -n does not move ─────────────────────────────────────────────
begin_test "wrap -n dry run does not move files"
setup_sandbox
mkdir target
touch a.txt
"$BASHD" wrap -n target >/dev/null 2>&1
assert_exists "a.txt" && assert_not_exists "target/a.txt" && pass
teardown_sandbox

# ── recase rejects multiple flags ─────────────────────────────────────
begin_test "recase rejects multiple flags"
setup_sandbox
touch a.txt
"$BASHD" recase -l -k >/dev/null 2>&1
assert_exit_nonzero $? && assert_exists "a.txt" && pass
teardown_sandbox

# ── pull refuses destination collision ────────────────────────────────
begin_test "pull refuses if name exists in parent"
setup_sandbox
mkdir inner
touch clash.txt inner/clash.txt
cd inner
"$BASHD" pull clash.txt >/dev/null 2>&1
assert_exit_nonzero $? && assert_exists "clash.txt" && pass
teardown_sandbox

# ── pfx optional file args ────────────────────────────────────────────
begin_test "pfx -d with file args only touches those files"
setup_sandbox
touch keep.txt only.jpg
"$BASHD" pfx -d only.jpg >/dev/null 2>&1
today=$(date +%Y_%m_%d)
assert_exists "keep.txt" && assert_exists "${today}_only.jpg" && assert_not_exists "only.jpg" && pass
teardown_sandbox

# ── byext organizes by extension ──────────────────────────────────────
begin_test "byext sorts files into extension dirs"
setup_sandbox
touch a.pdf b.jpg c
"$BASHD" byext >/dev/null 2>&1
assert_exists "pdf/a.pdf" && assert_exists "jpg/b.jpg" && assert_exists "noext/c" && pass
teardown_sandbox

# ── bydate uses GNU date -r ───────────────────────────────────────────
begin_test "bydate creates YYYY/MM/DD dirs"
setup_sandbox
touch report.txt
"$BASHD" bydate >/dev/null 2>&1
today=$(date +%Y/%m/%d)
assert_exists "$today/report.txt" && pass
teardown_sandbox

# ── bring copies into CWD ─────────────────────────────────────────────
begin_test "bring copies a file into CWD"
setup_sandbox
mkdir src dest
echo hi > src/note.txt
cd dest
"$BASHD" bring ../src/note.txt >/dev/null 2>&1
assert_exists "note.txt" && assert_exists "../src/note.txt" && pass
teardown_sandbox

# ── --help exits 0 ────────────────────────────────────────────────────
begin_test "core commands --help exits 0"
rc=0
for cmd in pfx sfx recase wrap uwrap nest flatten stick split byext bydate qc gaps trim pull bring clip; do
  "$BASHD" --help "$cmd" >/dev/null 2>&1 || rc=1
  "$BASHD" "$cmd" --help >/dev/null 2>&1 || rc=1
done
assert_equals "0" "$rc" && pass

print_summary
