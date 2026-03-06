# Source this once (e.g. in ~/.bashrc or ~/.zshrc) to set up Bashd.
# Adds script dirs to PATH and defines crush(), ld(), etc. so that running them also cds.

_script="${BASH_SOURCE[0]:-$0}"
BASHD_DIR="${BASHD_DIR:-$(cd "$(dirname "$_script")" && pwd)}"
BASHD_LASTDIR_FILE="${BASHD_LASTDIR_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/bashd/lastdir}"

export PATH="$PATH:${BASHD_DIR}:${BASHD_DIR}/scripts/cleanup:${BASHD_DIR}/scripts/fileTransfer:${BASHD_DIR}/scripts/system"

# Record previous CWD so 'ld' can return to it (update on each prompt when dir changes)
mkdir -p "$(dirname "$BASHD_LASTDIR_FILE")" 2>/dev/null
bashd_save_lastdir() {
  if [[ -n "${BASHD_CURRENT:-}" && "$PWD" != "$BASHD_CURRENT" ]]; then
    printf '%s' "$BASHD_CURRENT" > "$BASHD_LASTDIR_FILE"
  fi
  BASHD_CURRENT=$PWD
}
if [[ -n "${BASH_VERSION:-}" ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }bashd_save_lastdir"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  precmd_functions+=(bashd_save_lastdir)
fi

# crush: move CWD contents to parent, remove dir, and cd to parent (default behavior)
crush() { eval "$(command crush)"; }
ld() { eval "$(command ld)"; }
hop() { eval "$(command hop "$@")"; }
ndir() { eval "$(command ndir "$@")"; }
cdch() { eval "$(command cdch "$@")"; }
bm() {
  if [[ "$1" == "-a" || "$1" == "-d" || "$1" == "-l" ]]; then
    command bm "$@"
  else
    eval "$(command bm "$@")"
  fi
}
# mark: session breadcrumb trail — file lives in /tmp, cleaned up on shell exit
export BASHD_MARK_FILE="/tmp/bashd_marks_$$"
trap 'rm -f "$BASHD_MARK_FILE"' EXIT
mark() {
  if [[ "${1:-}" == "-a" || "${1:-}" == "-l" ]]; then
    command mark "$@"
  else
    eval "$(command mark "$@")"
  fi
}
tmpws() {
  local need_cwd=false
  for a in "$@"; do [[ "$a" == "-c" || "$a" == "--copy" ]] && need_cwd=true; done
  if $need_cwd; then
    eval "$(command tmpws "$@" "$(pwd)")"
  else
    eval "$(command tmpws "$@")"
  fi
}
# qs: quickSearch — menus/prompts go to stderr, only the chosen path to stdout; wrapper cd's there. qs -f runs without capturing stdout so the editor gets a real TTY.
qs() {
  local p
  if [[ "$1" == "-f" || "$1" == "--file" ]]; then
    command qs "$@"
  else
    p=$(command qs "$@")
    [[ -n "$p" && -d "$p" ]] && cd "$p"
  fi
}
