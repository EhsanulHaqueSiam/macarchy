#!/usr/bin/env bash
# The focused window, the way Hyprland's title reads.
#
# Omarchy's own bar has NO title widget, so this is a deliberate addition:
# without Cmd+Tab taking over window switching, the bar is the only feedback
# about which window is focused.
#
# Event-driven only - no update_freq. AeroSpace's on-focus-changed fires the
# same aerospace_workspace_change event this item subscribes to, and that fires
# for a focus change WITHIN a workspace too, so a poll would only add latency
# and a bash+aerospace spawn every couple of seconds.
source "$HOME/.config/sketchybar/theme.sh"

t=$(aerospace list-windows --focused --format '%{window-title}' 2>/dev/null | head -1)
[ -z "${t// /}" ] && t=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1)
# AeroSpace reports nothing for a floating panel or an empty workspace; the
# frontmost app is still the honest answer there.
[ -z "${t// /}" ] && t=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)

sketchybar --set "$NAME" label="$t"
