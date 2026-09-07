#!/usr/bin/env bash
source "$HOME/.config/sketchybar/theme.sh"
# macOS 14+ gates the SSID behind Location Services. Without that grant EVERY
# source returns the literal string "<redacted>" - verified on this machine:
#   ipconfig getsummary en1        -> SSID : <redacted>
#   system_profiler SPAirPortData  -> <redacted>:
#   networksetup -getairportnetwork-> "not associated" (dead on macOS 26)
# So a redacted SSID is treated as no SSID and the icon stands alone, which is
# what Omarchy's omarchy.network does anyway (icon in the bar, detail in panel).
# Grant Location Services to sketchybar if you want the name shown.
#   left click  known-network picker + Wi-Fi on/off
#   right click Network settings

dev=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2; exit}')
dev=${dev:-en1}

if [ "$SENDER" = "mouse.clicked" ]; then
  if [ "$BUTTON" = "right" ]; then
    open "x-apple.systempreferences:com.apple.Network-Settings.extension"
  else
    power=$(networksetup -getairportpower "$dev" 2>/dev/null | awk '{print $NF}')
    toggle="Turn Wi-Fi off"; [ "$power" = "Off" ] && toggle="Turn Wi-Fi on"
    nets=$(networksetup -listpreferredwirelessnetworks "$dev" 2>/dev/null | tail -n +2 \
           | sed 's/^[[:space:]]*//; s/"/\\"/g' | awk 'NF{printf "\"%s\",", $0}')
    choice=$(osascript -e "choose from list {${nets}\"$toggle\",\"Network settings…\"} with title \"Network\" with prompt \"Known networks\"" 2>/dev/null)
    case "$choice" in
      false|"") ;;
      "Turn Wi-Fi off") networksetup -setairportpower "$dev" off ;;
      "Turn Wi-Fi on")  networksetup -setairportpower "$dev" on ;;
      "Network settings…") open "x-apple.systempreferences:com.apple.Network-Settings.extension" ;;
      *) networksetup -setairportnetwork "$dev" "$choice" >/dev/null 2>&1 ;;
    esac
    sleep 1
  fi
fi

ssid=$(ipconfig getsummary "$dev" 2>/dev/null | awk -F' : ' '/^[[:space:]]*SSID : /{print $2; exit}')
case "$ssid" in *"<redacted>"*) ssid="" ;; esac

if ipconfig getifaddr "$dev" >/dev/null 2>&1; then
  if [ -n "$ssid" ]; then
    sketchybar --set "$NAME" icon="󰤨" icon.color=$FG label.drawing=on label="$ssid" label.max_chars=14
  else
    sketchybar --set "$NAME" icon="󰤨" icon.color=$FG label.drawing=off
  fi
elif ipconfig getifaddr en0 >/dev/null 2>&1; then
  sketchybar --set "$NAME" icon="󰈀" icon.color=$FG label.drawing=off
else
  sketchybar --set "$NAME" icon="󰤭" icon.color=$MUTED label.drawing=off
fi
