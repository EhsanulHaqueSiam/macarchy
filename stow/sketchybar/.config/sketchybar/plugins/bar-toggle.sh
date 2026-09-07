#!/usr/bin/env bash
# SUPER+SHIFT+SPACE: swap between the Omarchy bar and the real macOS menu bar.
#
# Omarchy's binding only hides the bar. Here it also un-hides the macOS menu
# bar, because SketchyBar sits at CG level 25 - above the menu bar's 24 - so
# hiding the bar alone still leaves you hovering for a menu bar you cannot see.
# `defaults write _HIHideMenuBar` needs a logout on macOS 26; the System Events
# `dock preferences` property applies immediately, so use that.
#
# ponytail: the 36px top gap stays reserved either way, which is what the menu
# bar needs anyway. Reclaiming it means rewriting ~/.aerospace.toml on every
# keypress; SUPER+SHIFT+BACKSPACE already does that.
source "$HOME/.config/sketchybar/theme.sh"
mkdir -p "$STATE"

menubar(){ osascript -e "tell application \"System Events\" to tell dock preferences to set autohide menu bar to $1" >/dev/null 2>&1; }

if [ "$(sketchybar --query bar | jq -r .hidden)" = "off" ]; then
  sketchybar --bar hidden=on   # Omarchy bar away
  menubar false                # real macOS menu bar stays down
else
  sketchybar --bar hidden=off  # Omarchy bar back
  menubar true                 # macOS menu bar auto-hides again
fi

sketchybar --query bar | jq -r .hidden > "$STATE/hidden"
