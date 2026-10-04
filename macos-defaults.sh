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

# macOS's own tiling (Sequoia+) fights AeroSpace: dragging to an edge snaps the
# window, and holding Option while dragging (Option is SUPER here) does too.
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
# Clicking the wallpaper (a gap between tiles) would shove every window aside.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# --- menu bar -------------------------------------------------------------
# The bar replaces it. `defaults` alone needs a logout on macOS 26, so also poke
# the live System Events property (this is what SUPER+SHIFT+SPACE toggles).
defaults write -g _HIHideMenuBar -bool true
osascript -e 'tell application "System Events" to tell dock preferences to set autohide menu bar to true' >/dev/null 2>&1 || true

# --- text editing, Omarchy style ------------------------------------------
# ⌥ is SUPER, so ⌥←/→ (macOS word jump) belong to the window manager. Give the
# Linux keys their Linux meaning instead: ⌃←/→ word, ⌃⌫/⌃⌦ delete word,
# Home/End line, ⌃Home/⌃End document, ⇧ to select. Cocoa and Electron/Chrome
# text fields read this; newly launched apps pick it up. Copied, not stowed:
# sandboxed apps cannot follow a symlink out of ~/Library.
mkdir -p "$HOME/Library/KeyBindings"
cat > "$HOME/Library/KeyBindings/DefaultKeyBinding.dict" <<'DICT'
{
  "^\UF702"  = "moveWordLeft:";
  "^\UF703"  = "moveWordRight:";
  "^$\UF702" = "moveWordLeftAndModifySelection:";
  "^$\UF703" = "moveWordRightAndModifySelection:";
  "^\U007F"  = "deleteWordBackward:";
  "^\UF728"  = "deleteWordForward:";
  "\UF729"   = "moveToBeginningOfLine:";
  "\UF72B"   = "moveToEndOfLine:";
  "$\UF729"  = "moveToBeginningOfLineAndModifySelection:";
  "$\UF72B"  = "moveToEndOfLineAndModifySelection:";
  "^\UF729"  = "moveToBeginningOfDocument:";
  "^\UF72B"  = "moveToEndOfDocument:";
  "^$\UF729" = "moveToBeginningOfDocumentAndModifySelection:";
  "^$\UF72B" = "moveToEndOfDocumentAndModifySelection:";
}
DICT
# ⌃←/→ (and ⇧) switch macOS Spaces by default, which AeroSpace never uses.
# Free them so the word jumps above reach apps. 79-82 = move left/right a space.
for id in 79 80 81 82; do
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add $id '{ enabled = 0; }'
done
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true

# --- screenshots ----------------------------------------------------------
# ⌘⇧3/4/5 and Screenshot.app land next to F13's, not on the Desktop.
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# --- default terminal -----------------------------------------------------
# macOS has no "default terminal" setting; the closest thing is owning the
# shell-script file types (double-click in Finder, `open foo.command`). ⌥Return
# and omarchy-mac-run already launch Ghostty directly.
for ext in sh tool zsh bash; do duti -s com.mitchellh.ghostty .$ext all; done
duti -s com.mitchellh.ghostty com.apple.terminal.shell-script all   # .command only takes the UTI

killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
echo "macOS defaults applied."
