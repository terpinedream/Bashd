#!/bin/bash
# Bashd test runner — runs all test_*.sh files or a specific one.
# Usage: ./run_tests.sh [test_file.sh ...]

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_FILES=0

run_test_file() {
  local f="$1"
  local name
  name=$(basename "$f")
  printf '\033[1m── %s ──\033[0m\n' "$name"
  if bash "$f"; then
    TOTAL_PASS=$((TOTAL_PASS + 1))
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  fi
  TOTAL_FILES=$((TOTAL_FILES + 1))
}

if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    if [[ -f "$TESTS_DIR/$arg" ]]; then
      run_test_file "$TESTS_DIR/$arg"
    elif [[ -f "$arg" ]]; then
      run_test_file "$arg"
    else
      echo "Not found: $arg" >&2
      (( TOTAL_FAIL++ ))
      (( TOTAL_FILES++ ))
    fi
  done
else
  for f in "$TESTS_DIR"/test_*.sh; do
    [[ -f "$f" ]] || continue
    run_test_file "$f"
  done
fi

echo ""
echo "========================================"
if [[ $TOTAL_FAIL -eq 0 ]]; then
  printf '\033[32mAll %d test files passed.\033[0m\n' "$TOTAL_FILES"
  exit 0
else
  printf '\033[31m%d of %d test files had failures.\033[0m\n' "$TOTAL_FAIL" "$TOTAL_FILES"
  exit 1
fi
