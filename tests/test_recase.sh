#!/bin/bash
source "$(dirname "$(readlink -f "$0")")/test_helpers.sh"

echo "Testing recase..."

# ── recase -l (lowercase) ────────────────────────────────────────────
begin_test "recase -l converts to lowercase"
setup_sandbox
touch "Hello_World.TXT"
"$BASHD" recase -l >/dev/null 2>&1
assert_exists "hello_world.txt" && pass
teardown_sandbox

# ── recase -u (UPPERCASE) ────────────────────────────────────────────
begin_test "recase -u converts to uppercase (ext stays lower)"
setup_sandbox
touch "hello_world.txt"
"$BASHD" recase -u >/dev/null 2>&1
assert_exists "HELLO_WORLD.txt" && pass
teardown_sandbox

# ── recase -c (camelCase) ────────────────────────────────────────────
begin_test "recase -c converts to camelCase"
setup_sandbox
touch "hello_world.txt"
"$BASHD" recase -c >/dev/null 2>&1
assert_exists "helloWorld.txt" && pass
teardown_sandbox

# ── recase -t (Title_Case) ───────────────────────────────────────────
begin_test "recase -t converts to Title_Case"
setup_sandbox
touch "hello_world.txt"
"$BASHD" recase -t >/dev/null 2>&1
assert_exists "Hello_World.txt" && pass
teardown_sandbox

# ── recase -k (kebab-case) ───────────────────────────────────────────
begin_test "recase -k converts to kebab-case"
setup_sandbox
touch "Hello_World.txt"
"$BASHD" recase -k >/dev/null 2>&1
assert_exists "hello-world.txt" && pass
teardown_sandbox

# ── recase + undo ─────────────────────────────────────────────────────
begin_test "recase -u then undo restores originals"
setup_sandbox
touch "hello.txt"
"$BASHD" recase -u >/dev/null 2>&1
"$BASHD" undo >/dev/null 2>&1
assert_exists "hello.txt" && pass
teardown_sandbox

print_summary
