# Setting Up Bashd

## Installation from AUR (Arch Linux)

```bash
yay -S bashd
# or
paru -S bashd
```

After installing, run `bashd` to see the full list of commands. All scripts are on your PATH. If you use a non-login shell and want `crush` and `hop` to change directory, add to `~/.bashrc` or `~/.zshrc`:

```bash
[ -f /usr/share/bashd/bashd-init.sh ] && . /usr/share/bashd/bashd-init.sh
```

---

## Manual installation (any Linux)

### 1. Clone the repository

```bash
git clone https://github.com/terpinedream/Bashd
cd Bashd
```

### 2. Copy scripts to a directory on your PATH

```bash
# Use /usr/local/bin or /usr/bin (sudo required for /usr/bin)
sudo cp scripts/* bashd /usr/local/bin/
# Or, if you prefer everything in one place:
sudo cp scripts/cleanme scripts/cram scripts/crush scripts/fold scripts/ufold \
      scripts/namechange scripts/pull scripts/stick scripts/flatten scripts/nest \
      scripts/hop scripts/trim scripts/prefix scripts/dedupe \
      scripts/archive scripts/bak scripts/pullfrom scripts/pushto scripts/dotsync \
      scripts/topd scripts/paclock bashd /usr/local/bin/
```

### 3. Set permissions

```bash
sudo chmod +x /usr/local/bin/cleanme /usr/local/bin/cram /usr/local/bin/crush \
  /usr/local/bin/fold /usr/local/bin/ufold /usr/local/bin/namechange \
  /usr/local/bin/pull /usr/local/bin/stick /usr/local/bin/flatten \
  /usr/local/bin/nest /usr/local/bin/hop /usr/local/bin/trim \
  /usr/local/bin/prefix /usr/local/bin/dedupe /usr/local/bin/archive \
  /usr/local/bin/bak /usr/local/bin/pullfrom /usr/local/bin/pushto \
  /usr/local/bin/dotsync /usr/local/bin/topd /usr/local/bin/paclock \
  /usr/local/bin/bashd
```

Or, if you copied all at once: `sudo chmod +x /usr/local/bin/*` (only in that directory).

### 4. Optional: make `crush` and `hop` change directory

Edit `~/.bashrc` (or `~/.zshrc`) and add:

```bash
# Replace /path/to/Bashd with the directory that contains bashd-init.sh
source /path/to/Bashd/bashd-init.sh
```

Verify:

```bash
type crush
# Should show: crush is a function
```

### 5. Run bashd

```bash
bashd
```

You should see the ASCII chart of all commands.
