#!/usr/bin/env bash
# Omarchy's omarchy.power widget: the battery on a laptop, a plain power glyph
# on a desktop. This Mac mini has no battery, so it is the glyph - but the
# laptop branch is here so the same config works if the bar ever moves.
source "$HOME/.config/sketchybar/theme.sh"
b=$(pmset -g batt)
pct=$(printf '%s' "$b" | /usr/bin/grep -Eo '[0-9]+%' | tr -d '%')

if [ -z "$pct" ]; then
  sketchybar --set "$NAME" icon="󰐥" icon.color=$FG label.drawing=off
  exit 0
fi

case "$b" in
  *"AC Power"*) i="󰂄"; c=$FG ;;
  *) if   [ "$pct" -le 20 ]; then i="󰁻"; c=$RED
     elif [ "$pct" -le 60 ]; then i="󰁽"; c=$FG
     else                          i="󰁹"; c=$FG; fi ;;
esac
sketchybar --set "$NAME" icon="$i" icon.color=$c label.drawing=on label="${pct}%"
