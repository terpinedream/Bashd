# Source this once (e.g. in ~/.bashrc or ~/.zshrc) to set up Bashd.
# Sets up the bashd dispatcher, shell helpers, and optional bare aliases.

_script="${BASH_SOURCE[0]:-$0}"
BASHD_DIR="${BASHD_DIR:-$(cd "$(dirname "$_script")" && pwd)}"
BASHD_LASTDIR_FILE="${BASHD_LASTDIR_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/bashd/lastdir}"

export PATH="$BASHD_DIR:$PATH"

# ── Prompt hooks (lastdir for ld, lastcmd for cpt) ───────────────────
mkdir -p "$(dirname "$BASHD_LASTDIR_FILE")" 2>/dev/null
export BASHD_LAST_CMD_FILE="/tmp/bashd_lastcmd_$$"

bashd_save_lastdir() {
  if [[ -n "${BASHD_CURRENT:-}" && "$PWD" != "$BASHD_CURRENT" ]]; then
    printf '%s' "$BASHD_CURRENT" > "$BASHD_LASTDIR_FILE"
  fi
  BASHD_CURRENT=$PWD
}
bashd_save_lastcmd() {
  local cmd
  cmd=$(fc -ln -1 2>/dev/null | sed 's/^[[:space:]]*//')
  [[ -n "$cmd" && "$cmd" != "cpt"* ]] && printf '%s' "$cmd" > "$BASHD_LAST_CMD_FILE"
}
if [[ -n "${BASH_VERSION:-}" ]]; then
  PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }bashd_save_lastdir; bashd_save_lastcmd"
elif [[ -n "${ZSH_VERSION:-}" ]]; then
  precmd_functions+=(bashd_save_lastdir bashd_save_lastcmd)
fi

# ── Session files (mark trail, lastcmd) ──────────────────────────────
export BASHD_MARK_FILE="/tmp/bashd_marks_$$"
trap 'rm -f "$BASHD_MARK_FILE" "$BASHD_LAST_CMD_FILE"' EXIT

# ── CD-requiring helpers ─────────────────────────────────────────────
# These wrappers eval the script output so cd commands affect the shell.
_bashd_cd_helpers="hop ndir crush ld cdch"

crush() { eval "$(bashd crush)"; }
ld()    { eval "$(bashd ld)"; }
hop()   { eval "$(bashd hop "$@")"; }
ndir()  { eval "$(bashd ndir "$@")"; }
cdch()  { eval "$(bashd cdch "$@")"; }

bm() {
  if [[ "${1:-}" == "-a" || "${1:-}" == "-d" || "${1:-}" == "-l" ]]; then
    bashd bm "$@"
  else
    eval "$(bashd bm "$@")"
  fi
}

mark() {
  if [[ "${1:-}" == "-a" || "${1:-}" == "-l" ]]; then
    bashd mark "$@"
  else
    eval "$(bashd mark "$@")"
  fi
}

tmpws() {
  local need_cwd=false
  for a in "$@"; do [[ "$a" == "-c" || "$a" == "--copy" ]] && need_cwd=true; done
  if [[ "${1:-}" == "-r" || "${1:-}" == "--return" ]]; then
    eval "$(bashd tmpws "$@")"
  elif $need_cwd; then
    eval "$(bashd tmpws "$@" "$(pwd)")"
  else
    eval "$(bashd tmpws "$@")"
  fi
}

qs() {
  local p
  if [[ "${1:-}" == "-f" || "${1:-}" == "--file" ]]; then
    bashd qs "$@"
  else
    p=$(bashd qs "$@")
    [[ -n "$p" && -d "$p" ]] && cd "$p"
  fi
}

# ── Config-driven aliases ────────────────────────────────────────────
# Read ~/.config/bashd/aliases.conf (if present) and create bare
# aliases for listed commands so they can run without the `bashd` prefix.
# If the config doesn't exist, all core + helper commands get aliases
# by default (backward compatible).

_bashd_alias_conf="${XDG_CONFIG_HOME:-$HOME/.config}/bashd/aliases.conf"
_bashd_cd_set=" hop ndir crush tmpws bm mark ld cdch qs "

_bashd_setup_aliases() {
  local cmds=()

  if [[ -f "$_bashd_alias_conf" ]]; then
    while IFS= read -r _line; do
      _line="${_line%%#*}"
      _line="$(echo "$_line" | tr -d '[:space:]')"
      [[ -z "$_line" ]] && continue
      cmds+=("$_line")
    done < "$_bashd_alias_conf"
  else
    # No config — alias everything (backward compatible)
    local all
    all=$(bashd --list all 2>/dev/null | grep -E '^ ' | tr -d ' ')
    while IFS= read -r _line; do
      [[ -n "$_line" ]] && cmds+=("$_line")
    done <<< "$all"
  fi

  for _cmd in "${cmds[@]}"; do
    # Skip cd-helpers — they already have proper shell function wrappers above
    [[ "$_bashd_cd_set" == *" $_cmd "* ]] && continue
    # Don't override existing functions/builtins
    type "$_cmd" &>/dev/null && continue
    alias "$_cmd=bashd $_cmd"
  done
}

_bashd_setup_aliases
unset -f _bashd_setup_aliases
unset _bashd_alias_conf _bashd_cd_set
