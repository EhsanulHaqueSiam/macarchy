#!/usr/bin/env bash
# Omarchy on macOS - one-command setup.
#   ./install.sh            everything
#   ./install.sh --no-brew  skip the Brewfile (fast re-link)
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
say(){ printf '\n\033[1m==> %s\033[0m\n' "$*"; }

[ "$(uname -s)" = Darwin ] || { echo "macOS only." >&2; exit 1; }

if [ "${1:-}" != "--no-brew" ]; then
  say "Homebrew"
  command -v brew >/dev/null 2>&1 || \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  say "Packages"
  # Homebrew will not load third-party tap formulae until they are trusted, and
  # `brew bundle` fails outright without it. Tap and trust first.
  for t in felixkratz/formulae nikitabobko/tap smudge/smudge asmvik/formulae; do
    brew tap "$t" >/dev/null 2>&1 || true
    brew trust --tap "$t" >/dev/null 2>&1 || true
  done
  brew bundle --file="$REPO/Brewfile"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

say "Linking configs (GNU stow)"
mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.local/state/sketchybar"
(cd "$REPO" && stow --restow aerospace skhd sketchybar borders bin zsh)  # .stowrc sets --dir/--target

# AeroSpace's TOML cannot expand $HOME, so exec.env-vars carries absolute paths.
# stow symlinks the file, so this edits the repo copy - which is correct: your
# clone should hold your paths.
if ! /usr/bin/grep -q "PATH = '$HOME/.local/bin" "$HOME/.aerospace.toml"; then
  say "Rewriting baked-in paths for $(whoami)"
  sed -i '' -E "s|/Users/[a-zA-Z0-9._-]+|$HOME|g; s|USER = '[^']*'|USER = '$(whoami)'|" "$HOME/.aerospace.toml"
fi

say "macOS defaults"
"$REPO/macos-defaults.sh"

say "Theme colours (bar + borders)"
"$HOME/.local/bin/omarchy-mac-colors" || echo "  (no active omarchy theme yet - skipped)"

say "Services"
skhd --install-service 2>/dev/null || true
skhd --start-service   2>/dev/null || skhd --restart-service 2>/dev/null || true
brew services start sketchybar >/dev/null 2>&1 || brew services restart sketchybar >/dev/null 2>&1 || true
brew services start borders    >/dev/null 2>&1 || brew services restart borders    >/dev/null 2>&1 || true
open -a AeroSpace 2>/dev/null || true
sleep 3

say "Health check"
"$HOME/.local/bin/omarchy-mac-doctor" || true

cat <<'NOTE'

Grant these by hand (macOS will not let a script do it):
  System Settings > Privacy & Security > Accessibility   -> AeroSpace, borders
  System Settings > Privacy & Security > Input Monitoring -> skhd
  Control Center  > Menu Bar Only > Automatically hide and show the menu bar -> Always

PC keyboard? Put SUPER on the Win key:   omarchy-mac-keyboard-super
Then re-run:                             omarchy-mac-doctor
Keybindings cheat sheet:                 Option+K
NOTE
