#!/usr/bin/env bash
# Repaints every workspace pill in ONE sketchybar call: 2 aerospace calls + 1
# sketchybar call per event, instead of 11 + 11.
#
# Omarchy's rule (default/hypr/../widgets/Workspaces.qml):
#   - 1..5 are ALWAYS drawn, plus any occupied workspace up to 10
#   - the focused one is a filled dot, not its number
#   - occupied = full opacity, empty = 0.5
# S (scratchpad) is the one addition: Hyprland's special workspace has no pill
# in Omarchy, but without it ⌥S leaves no pill lit at all.
source "$HOME/.config/sketchybar/theme.sh"

FOCUSED_GLYPH="󱓻"

focused="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
occupied=" $(aerospace list-workspaces --monitor all --empty no 2>/dev/null | tr '\n' ' ')"

args=()
for sid in 1 2 3 4 5 6 7 8 9 10 S; do
  label="$sid"; [ "$sid" = "10" ] && label="0"
  if [ "$sid" = "$focused" ]; then
    args+=(--set "space.$sid" drawing=on label="$FOCUSED_GLYPH" \
           label.color=$FG label.font="$ICONS:Regular:13.0")
  elif [[ $occupied == *" $sid "* ]]; then
    args+=(--set "space.$sid" drawing=on label="$label" \
           label.color=$FG label.font="$FONT:Regular:12.0")
  elif [ "$sid" != "S" ] && [ "$sid" -le 5 ] 2>/dev/null; then
    args+=(--set "space.$sid" drawing=on label="$label" \
           label.color=$DIM label.font="$FONT:Regular:12.0")
  else
    args+=(--set "space.$sid" drawing=off)
  fi
done
sketchybar "${args[@]}"
