# Source this once (e.g. in ~/.bashrc or ~/.zshrc) to set up Bashd.
# Defines crush() and hop() so that running 'crush' or 'hop' changes the shell directory.
# Scripts are expected to be on PATH (e.g. installed in /usr/bin or /usr/local/bin).

# crush: move CWD contents to parent, remove dir, and cd to parent (default behavior)
crush() { eval "$( command crush )"; }
# hop: quick dir jumps (hop N = up N levels; hop name = nearest parent matching name)
hop() { eval "$( command hop "$@" )"; }
