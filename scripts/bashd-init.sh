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
tmpws() { eval "$(command tmpws)"; }
