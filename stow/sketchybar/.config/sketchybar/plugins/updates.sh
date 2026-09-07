#!/usr/bin/env bash
source "$HOME/.config/sketchybar/theme.sh"
# NO_AUTO_UPDATE keeps this off the network; it reads the local formula cache.
n=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null | /usr/bin/grep -c .)
if [ "$n" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$n"
else
  sketchybar --set "$NAME" drawing=off
fi
