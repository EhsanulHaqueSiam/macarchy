#!/usr/bin/env bash
# Omarchy's omarchy.audio widget: an icon in the bar, a panel on click.
#   scroll      change volume
#   left click  mute / unmute
#   right click output-device picker + Sound settings
source "$HOME/.config/sketchybar/theme.sh"

read -r vol muted <<<"$(osascript -e 'set s to get volume settings' \
  -e '(output volume of s as text) & " " & (output muted of s as text)' 2>/dev/null)"
vol=${vol:-0}

case "$SENDER" in
  mouse.scrolled)
    step=5
    [ "${SCROLL_DELTA:-0}" = "${SCROLL_DELTA#-}" ] || step=-5
    new=$(( vol + step )); [ $new -gt 100 ] && new=100; [ $new -lt 0 ] && new=0
    osascript -e "set volume output volume $new" -e "set volume without output muted" 2>/dev/null
    vol=$new; muted=false
    ;;
  mouse.clicked)
    case "$BUTTON" in
      right)
        cur=$(SwitchAudioSource -c 2>/dev/null)
        list=$(SwitchAudioSource -a -t output 2>/dev/null | sed 's/"/\\"/g' | awk '{printf "\"%s\",", $0}')
        choice=$(osascript -e "choose from list {${list}\"Sound settings…\"} with title \"Audio\" with prompt \"Output device (now: $cur)\"" 2>/dev/null)
        case "$choice" in
          false|"") ;;
          "Sound settings…") open "x-apple.systempreferences:com.apple.Sound-Settings.extension" ;;
          *) SwitchAudioSource -s "$choice" >/dev/null 2>&1 ;;
        esac
        ;;
      *)
        if [ "$muted" = "true" ]; then osascript -e 'set volume without output muted'; muted=false
        else osascript -e 'set volume with output muted'; muted=true; fi
        ;;
    esac
    ;;
esac

if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then i="󰝟"; c=$MUTED
elif [ "$vol" -lt 34 ]; then i="󰕿"; c=$FG
elif [ "$vol" -lt 67 ]; then i="󰖀"; c=$FG
else i="󰕾"; c=$FG; fi
sketchybar --set "$NAME" icon="$i" icon.color=$c label="${vol}%"
