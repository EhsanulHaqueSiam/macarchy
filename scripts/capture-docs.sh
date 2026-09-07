#!/usr/bin/env bash
# Generate the screenshots and GIFs in docs/, then add the gallery to README.md.
#
# RUN THIS ON THE MAC ITSELF, in your own GUI session:
#     make docs        (or)   ./scripts/capture-docs.sh
#
# It cannot run over ssh. macOS gates screen capture behind a Screen Recording
# grant, and that cannot be given to sshd from the command line, so screencapture
# just fails with "could not create image from display".
#
# It opens throwaway Ghostty windows on an empty workspace, captures the bar and
# the tiling behaviour, records a short clip of workspace switching and split
# flipping, converts it to a GIF, then closes what it opened.
set -uo pipefail
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$REPO/docs"; mkdir -p "$OUT"
AS=/opt/homebrew/bin/aerospace
SC=/usr/sbin/screencapture

bounds=$(osascript -e 'tell application "Finder" to get bounds of window of desktop')
W=$(printf '%s' "$bounds" | awk -F', ' '{print $3}')
echo "display width ${W}"

WS=""
for c in 8 9 7 6; do
  [ "$($AS list-windows --workspace $c --count 2>/dev/null || echo 0)" = "0" ] && { WS=$c; break; }
done
[ -z "$WS" ] && { echo "no empty workspace free; close something and retry" >&2; exit 1; }
echo "using workspace $WS"

shot(){ sleep 1.2; $SC -x -o "$OUT/$1.png"; echo "  $1.png"; }
crop(){ sleep 1.2; $SC -x -R"$2" "$OUT/$1.png"; echo "  $1.png"; }
fire(){ $AS trigger-binding "$1" --mode main 2>/dev/null; sleep 1.2; }

$AS workspace "$WS"; sleep 1
for i in 1 2 3; do open -na Ghostty; sleep 2.5; done
$AS workspace "$WS"; sleep 2

echo "stills:"
crop bar "0,0,${W},30"
shot tiling-three-columns
fire alt-j;        shot tiling-vertical-split
fire alt-j
fire alt-cmd-left; shot tiling-mixed-split
fire alt-cmd-g
fire alt-g;        shot tiling-accordion
fire alt-g

echo "recording:"
rm -f /tmp/macarchy-demo.mov
$SC -v -V 16 -x -C /tmp/macarchy-demo.mov &
REC=$!
sleep 2
for b in alt-1 alt-2 alt-3 alt-j alt-cmd-left alt-cmd-g alt-f alt-f alt-5 "alt-$WS"; do fire "$b"; done
wait $REC 2>/dev/null

echo "gif:"
ffmpeg -y -i /tmp/macarchy-demo.mov \
  -vf "fps=10,scale=900:-2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  "$OUT/demo.gif" >/dev/null 2>&1 && echo "  demo.gif ($(du -h "$OUT/demo.gif" | cut -f1))"
rm -f /tmp/macarchy-demo.mov

echo "cleanup:"
for id in $($AS list-windows --workspace "$WS" --format '%{window-id} %{app-name}' | /usr/bin/grep -i ghostty | awk '{print $1}'); do
  $AS close --window-id "$id" 2>/dev/null
done
$AS workspace 1 >/dev/null 2>&1
echo "  done"

# Only add the gallery once the images exist, so the published README never
# shows broken image links.
/usr/bin/python3 "$REPO/scripts/_gallery.py" "$REPO"

echo
echo "Now commit them:"
echo "  cd $REPO && git add -A && git commit -m 'Add screenshots and demo gif' && git push"
