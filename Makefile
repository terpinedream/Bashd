PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
BASHD   := $(BINDIR)/bashd

SCRIPTS_DIR := scripts
CORE_DIR    := $(SCRIPTS_DIR)/core
HELPERS_DIR := $(SCRIPTS_DIR)/helpers
EXTRA_DIR   := $(SCRIPTS_DIR)/extra

INSTALL_DIR := $(BINDIR)/bashd-scripts
INSTALL_CORE := $(INSTALL_DIR)/core
INSTALL_HELP := $(INSTALL_DIR)/helpers
INSTALL_EXTRA := $(INSTALL_DIR)/extra

.PHONY: test install-core install-extra install-all uninstall help

help:
	@echo "Bashd Makefile targets:"
	@echo "  make test           Run the test suite"
	@echo "  make install-core   Install dispatcher + core + helpers"
	@echo "  make install-extra  Install extra scripts (requires install-core)"
	@echo "  make install-all    Install everything"
	@echo "  make uninstall      Remove all installed files"
	@echo ""
	@echo "Variables:"
	@echo "  PREFIX=$(PREFIX)  (install root, default /usr/local)"
	@echo ""
	@echo "After install, add to your shell rc:"
	@echo '  source "$(INSTALL_DIR)/bashd-init.sh"'

test:
	@bash tests/run_tests.sh

install-core:
	@echo "Installing Bashd core to $(INSTALL_DIR)..."
	install -d $(INSTALL_DIR) $(INSTALL_CORE) $(INSTALL_HELP)
	install -m 755 $(SCRIPTS_DIR)/bashd $(BASHD)
	install -m 755 $(SCRIPTS_DIR)/bashd-init.sh $(INSTALL_DIR)/bashd-init.sh
	install -m 644 $(SCRIPTS_DIR)/_bashd_log $(INSTALL_DIR)/_bashd_log
	install -m 644 $(SCRIPTS_DIR)/_bashd_files $(INSTALL_DIR)/_bashd_files
	install -m 644 $(SCRIPTS_DIR)/_bashd_clip $(INSTALL_DIR)/_bashd_clip
	install -m 644 $(SCRIPTS_DIR)/_bashd_remote $(INSTALL_DIR)/_bashd_remote
	@for f in $(CORE_DIR)/*; do install -m 755 "$$f" $(INSTALL_CORE)/; done
	@for f in $(HELPERS_DIR)/*; do install -m 755 "$$f" $(INSTALL_HELP)/; done
	@echo "Installed core + helpers."
	@echo 'Add to your shell rc:  source "$(INSTALL_DIR)/bashd-init.sh"'

install-extra: install-core
	@echo "Installing Bashd extra scripts..."
	install -d $(INSTALL_EXTRA)
	@for f in $(EXTRA_DIR)/*; do install -m 755 "$$f" $(INSTALL_EXTRA)/; done
	@echo "Installed extra scripts."

install-all: install-core install-extra
	@echo "Full Bashd installation complete."

uninstall:
	@echo "Removing Bashd from $(INSTALL_DIR) and $(BASHD)..."
	rm -f $(BASHD)
	rm -rf $(INSTALL_DIR)
	@echo "Uninstalled."
