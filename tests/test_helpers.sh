#!/bin/bash
# Bashd test helper functions — sourced by individual test files.

BASHD_ROOT="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
BASHD="$BASHD_ROOT/scripts/bashd"
_PASS=0
_FAIL=0
_TOTAL=0
_CURRENT_TEST=""

# ── Setup / Teardown ─────────────────────────────────────────────────
setup_sandbox() {
  _SANDBOX=$(mktemp -d)
  cd "$_SANDBOX" || exit 1
}

teardown_sandbox() {
  cd /tmp || true
  [[ -n "${_SANDBOX:-}" && -d "$_SANDBOX" ]] && rm -rf "$_SANDBOX"
}

# ── Test lifecycle ────────────────────────────────────────────────────
begin_test() {
  _CURRENT_TEST="$1"
  _TOTAL=$((_TOTAL + 1))
}

pass() {
  _PASS=$((_PASS + 1))
  printf '  \033[32m✓\033[0m %s\n' "$_CURRENT_TEST"
}

fail() {
  _FAIL=$((_FAIL + 1))
  printf '  \033[31m✗\033[0m %s — %s\n' "$_CURRENT_TEST" "$1"
}

# ── Assertions ────────────────────────────────────────────────────────
assert_exists() {
  if [[ -e "$1" ]]; then
    return 0
  else
    fail "expected '$1' to exist"
    return 1
  fi
}

assert_not_exists() {
  if [[ ! -e "$1" ]]; then
    return 0
  else
    fail "expected '$1' to NOT exist"
    return 1
  fi
}

assert_file_count() {
  local expected="$1"
  local dir="${2:-.}"
  local actual
  actual=$(find "$dir" -maxdepth 1 -not -name '.' -not -name '..' | wc -l)
  actual="${actual// /}"
  if [[ "$actual" == "$expected" ]]; then
    return 0
  else
    fail "expected $expected items in $dir, got $actual"
    return 1
  fi
}

assert_name_matches() {
  local pattern="$1"
  local dir="${2:-.}"
  if ls "$dir" | grep -qE "$pattern"; then
    return 0
  else
    fail "no file matching pattern '$pattern' in $dir"
    return 1
  fi
}

assert_equals() {
  if [[ "$1" == "$2" ]]; then
    return 0
  else
    fail "expected '$1', got '$2'"
    return 1
  fi
}

assert_exit_zero() {
  if [[ "$1" -eq 0 ]]; then
    return 0
  else
    fail "expected exit 0, got $1"
    return 1
  fi
}

assert_exit_nonzero() {
  if [[ "$1" -ne 0 ]]; then
    return 0
  else
    fail "expected non-zero exit, got 0"
    return 1
  fi
}

# ── Summary ───────────────────────────────────────────────────────────
print_summary() {
  echo ""
  if [[ $_FAIL -eq 0 ]]; then
    printf '\033[32mAll %d tests passed.\033[0m\n' "$_TOTAL"
  else
    printf '\033[31m%d of %d tests failed.\033[0m\n' "$_FAIL" "$_TOTAL"
  fi
  return "$_FAIL"
}
