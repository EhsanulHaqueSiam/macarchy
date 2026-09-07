# Omarchy on macOS. `.stowrc` points stow at ./stow -> $HOME, so the stow
# targets below need no flags.
PKGS := aerospace skhd sketchybar borders bin

.PHONY: help install link relink unlink brew trust defaults colors services doctor verify keys dump docs
.DEFAULT_GOAL := help

help:            ## show this help
	@grep -hE '^[a-z-]+:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/\t/' | column -t -s "$$(printf '\t')"

install:         ## full setup: brew, link, macOS defaults, services
	@./install.sh

link:            ## symlink the configs into $HOME
	@stow $(PKGS) && echo "linked: $(PKGS)"

relink:          ## re-link after adding or renaming files
	@stow -R $(PKGS) && echo "relinked: $(PKGS)"

unlink:          ## remove the symlinks; the configs stay here in the repo
	@stow -D $(PKGS) && echo "unlinked: $(PKGS)"

brew:            ## install the Brewfile
	@brew bundle --file=Brewfile

trust:           ## trust the third-party taps (brew refuses to load them otherwise)
	@for t in felixkratz/formulae nikitabobko/tap smudge/smudge asmvik/formulae; do \
		brew tap $$t >/dev/null 2>&1 || true; brew trust --tap $$t || true; done

defaults:        ## apply the macOS settings this rig depends on
	@./macos-defaults.sh

colors:          ## rebuild bar + border colours from the active Omarchy theme
	@omarchy-mac-colors

services:        ## restart aerospace, skhd, sketchybar, borders
	@aerospace reload-config || true
	@skhd --restart-service || true
	@sketchybar --reload || true
	@brew services restart borders >/dev/null || true

doctor:          ## health check
	@macarchy doctor

verify:          ## functional regression suite
	@macarchy verify

keys:            ## print the keybinding cheat sheet
	@omarchy-mac-keys-gen

docs:            ## capture screenshots + demo gif (run ON the Mac, not over ssh)
	@./scripts/capture-docs.sh

dump:            ## refresh Brewfile.full from this machine
	@brew bundle dump --file=Brewfile.full --force && echo "Brewfile.full updated"
