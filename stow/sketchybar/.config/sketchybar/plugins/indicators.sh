#!/usr/bin/env bash
# Omarchy's omarchy.indicators: transient state that is otherwise invisible.
# It shows nothing at all when nothing is active, which is the point.
# Of Omarchy's set (Dictation ScreenRecording Reminder NightLight Dnd StayAwake)
# these three are the ones macOS exposes without private APIs. Focus/DnD state
# has no readable store on macOS 26 - Assertions.json is gone - so it is absent
# rather than guessed.
source "$HOME/.config/sketchybar/theme.sh"

glyphs=""
pgrep -x screencapture >/dev/null && glyphs+="󰑊 "                      # recording
[ "$(nightlight status 2>/dev/null)" = "on" ] && glyphs+="󰛨 "          # night shift
pgrep -x caffeinate >/dev/null && glyphs+="󰅶 "                         # idle inhibited

if [ -n "$glyphs" ]; then
  sketchybar --set "$NAME" drawing=on icon="${glyphs% }" icon.color=$ACCENT
else
  sketchybar --set "$NAME" drawing=off
fi
