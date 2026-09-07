#!/usr/bin/env bash
# Omarchy's omarchy.bluetooth widget.
#   left click  power toggle + connect/disconnect a paired device
#   right click Bluetooth settings
source "$HOME/.config/sketchybar/theme.sh"

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$BUTTON" = "right" ]; then
    open "x-apple.systempreferences:com.apple.BluetoothSettings"
  else
    on=$(blueutil -p 2>/dev/null)
    toggle="Turn Bluetooth on"; [ "$on" = "1" ] && toggle="Turn Bluetooth off"
    devs=""
    if [ "$on" = "1" ]; then
      devs=$(blueutil --paired 2>/dev/null | sed -E 's/^address: ([^,]+).*name: "([^"]*)".*/\2 [\1]/' \
             | sed 's/"/\\"/g' | awk 'NF{printf "\"%s\",", $0}')
    fi
    choice=$(osascript -e "choose from list {${devs}\"$toggle\",\"Bluetooth settings…\"} with title \"Bluetooth\" with prompt \"Devices\"" 2>/dev/null)
    case "$choice" in
      false|"") ;;
      "Turn Bluetooth on")  blueutil -p 1 ;;
      "Turn Bluetooth off") blueutil -p 0 ;;
      "Bluetooth settings…") open "x-apple.systempreferences:com.apple.BluetoothSettings" ;;
      *) id=$(printf '%s' "$choice" | sed -E 's/.*\[(.*)\]$/\1/')
         if [ "$(blueutil --is-connected "$id" 2>/dev/null)" = "1" ]; then blueutil --disconnect "$id"
         else blueutil --connect "$id"; fi ;;
    esac
    sleep 1
  fi
fi

if [ "$(blueutil -p 2>/dev/null)" = "1" ]; then
  n=$(blueutil --connected 2>/dev/null | /usr/bin/grep -c .)
  [ "$n" -gt 0 ] && { i="󰂱"; c=$FG; } || { i="󰂯"; c=$MUTED; }
else i="󰂲"; c=$MUTED; fi
sketchybar --set "$NAME" icon="$i" icon.color=$c label.drawing=off
