#!/usr/bin/env bash
# Sourced by sketchybarrc and every plugin, so colours AND PATH live in one
# place - brew services gives sketchybar a minimal PATH and its child scripts
# inherit it, which is how `aerospace: command not found` happens.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# omarchy-mac-colors regenerates this from the active theme's colors.toml.
# Without it (no theme applied yet) fall back to last-horizon.
[ -r "$HOME/.config/omarchy-mac/colors.sh" ] && . "$HOME/.config/omarchy-mac/colors.sh"

BG=${BAR_BG:-0xff0c0b0c}
FG=${BAR_FG:-0xffFAFCFB}
MUTED=${BAR_MUTED:-0xff584e51}
ACCENT=${BAR_ACCENT:-0xffb59790}
RED=${BAR_RED:-0xffc38b7b}
# Omarchy dims an unoccupied workspace to opacity 0.5 rather than recolouring
# it, so DIM is the foreground at half alpha - derived, never a second colour.
DIM="0x80${FG#0x??}"

FONT="JetBrainsMono Nerd Font"
ICONS="Symbols Nerd Font Mono"
STATE="$HOME/.local/state/sketchybar"
