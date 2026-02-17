# Source this once (e.g. in ~/.bashrc or ~/.zshrc) to set up Bashd.
# Adds script dirs to PATH and defines crush() so that running 'crush' also cds to parent.

_script="${BASH_SOURCE[0]:-$0}"
BASHD_DIR="${BASHD_DIR:-$(cd "$(dirname "$_script")" && pwd)}"

export PATH="$PATH:${BASHD_DIR}:${BASHD_DIR}/scripts/cleanup:${BASHD_DIR}/scripts/fileTransfer:${BASHD_DIR}/scripts/system"

# crush: move CWD contents to parent, remove dir, and cd to parent (default behavior)
crush() { eval "$(command crush)"; }
hop() { eval "$(command hop "$@")"; }
ndir() { eval "$(command ndir "$@")"; }
cdch() { eval "$(command cdch "$@")"; }
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
