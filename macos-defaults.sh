#!/usr/bin/env bash
# The macOS settings this rig depends on. Safe to re-run.
set -euo pipefail

# --- window-manager snappiness -------------------------------------------
# AeroSpace's guide: macOS is more stable with "Displays have separate Spaces" off.
defaults write com.apple.spaces spans-displays -bool true
# The visible lag when AeroSpace retiles.
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock workspaces-swoosh-animation-off -bool true
# Biggest single win for workspace switching.
defaults write com.apple.universalaccess reduceMotion -bool true
# Ctrl+Cmd+drag anywhere on a window to move it - Hyprland's SUPER+drag analog.
defaults write -g NSWindowShouldDragOnGesture -bool true

# --- menu bar -------------------------------------------------------------
# The bar replaces it. `defaults` alone needs a logout on macOS 26, so also poke
# the live System Events property (this is what SUPER+SHIFT+SPACE toggles).
defaults write -g _HIHideMenuBar -bool true
osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true' >/dev/null 2>&1 || true

# --- default terminal -----------------------------------------------------
# macOS has no "default terminal" setting; the closest thing is owning the
# shell-script file types (double-click in Finder, `open foo.command`). ⌥Return
# and omarchy-mac-run already launch Ghostty directly.
for ext in sh tool zsh bash; do duti -s com.mitchellh.ghostty .$ext all; done
duti -s com.mitchellh.ghostty com.apple.terminal.shell-script all   # .command only takes the UTI

killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
echo "macOS defaults applied."
