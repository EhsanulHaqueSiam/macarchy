#!/usr/bin/env bash
source "$HOME/.config/sketchybar/theme.sh"
# Omarchy's system-update counter: brew + App Store + mise, summed.
# NO_AUTO_UPDATE keeps brew off the network; mise reads its remote-version cache.
b=$(HOMEBREW_NO_AUTO_UPDATE=1 brew outdated --quiet 2>/dev/null | /usr/bin/grep -c .)
a=$(mas outdated 2>/dev/null | /usr/bin/grep -c .)
m=$(mise outdated --json 2>/dev/null | jq 'length' 2>/dev/null)
n=$(( ${b:-0} + ${a:-0} + ${m:-0} ))
if [ "$n" -gt 0 ]; then
  sketchybar --set "$NAME" drawing=on label="$n"
else
  sketchybar --set "$NAME" drawing=off
fi
