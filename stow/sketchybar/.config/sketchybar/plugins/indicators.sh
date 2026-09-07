#!/usr/bin/env bash
# Omarchy's omarchy.indicators: transient state that is otherwise invisible.
# Shows nothing at all when nothing is active, which is the point.
#
# Of Omarchy's set (Dictation ScreenRecording Reminder NightLight Dnd StayAwake)
# these three are the ones macOS exposes without private APIs. Focus/DnD has no
# readable store on macOS 26 (Assertions.json is gone), so it is absent rather
# than guessed.
#
#   left click   toggle stay-awake (the cup)
#   right click  toggle night shift
source "$HOME/.config/sketchybar/theme.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  case "$BUTTON" in
    right) "$HOME/.local/bin/omarchy-mac-nightlight" ;;
    *)     "$HOME/.local/bin/omarchy-mac-idle" ;;
  esac
  sleep 1
fi

glyphs=""
pgrep -x screencapture >/dev/null && glyphs+="󰑊 "                      # recording
[ "$(nightlight status 2>/dev/null)" = "on" ] && glyphs+="󰛨 "          # night shift
pgrep -x caffeinate >/dev/null && glyphs+="󰅶 "                         # stay awake

if [ -n "$glyphs" ]; then
  sketchybar --set "$NAME" drawing=on icon="${glyphs% }" icon.color=$ACCENT
else
  sketchybar --set "$NAME" drawing=off
fi
