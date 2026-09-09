# Everything the Omarchy-on-macOS rig needs. `Brewfile.full` is a dump of the
# whole machine if you are rebuilding it rather than just installing this.
tap "felixkratz/formulae"
tap "nikitabobko/tap"
tap "smudge/smudge"
tap "asmvik/formulae"   # skhd moved here from koekeishiya
tap "dimentium/autoraise"

# window manager, hotkeys, bar, borders
cask "aerospace"
brew "felixkratz/formulae/borders"
brew "felixkratz/formulae/sketchybar"
brew "asmvik/formulae/skhd"
brew "dimentium/autoraise/autoraise"   # focus follows mouse

# used by the bar and the bindings
brew "blueutil"          # bluetooth widget
brew "switchaudio-osx"   # audio output switching
brew "smudge/smudge/nightlight"  # night shift toggle + indicator
brew "jq"                # every sketchybar plugin
brew "stow"              # this repo's installer
brew "displayplacer"     # omarchy-mac-scale
brew "ffmpeg"            # omarchy-mac-transcode
brew "imagemagick"       # omarchy-mac-transcode
brew "fzf"               # omarchy-mac-keys
brew "duti"              # macos-defaults.sh: Ghostty as the default terminal

# terminal + TUIs the bindings launch
cask "ghostty"
brew "btop"
brew "lazydocker"
brew "lazygit"
brew "neovim"
brew "tmux"

# omarchy.zsh shell defaults
brew "zoxide"
brew "starship"
brew "eza"
brew "bat"

# fonts the bar draws with
cask "font-jetbrains-mono-nerd-font"
cask "font-symbols-only-nerd-font"
