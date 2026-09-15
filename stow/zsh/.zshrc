
# mise (node etc.)
eval "$(mise activate zsh)"
export PATH="$HOME/.local/bin:$PATH"
# Android SDK (installed via sdkmanager, no Studio wizard)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
# Java for Android tooling and maestro (Android Studio's bundled JBR hangs from a shell)
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$HOME/.maestro/bin:$PATH"
# Metro/Expo advertise the Tailscale IP so the phone and omarchy reach the dev
# server. Computed, not hardcoded: this file is shared between two machines,
# and each has its own Tailscale IP.
export REACT_NATIVE_PACKAGER_HOSTNAME=$(tailscale ip -4 2>/dev/null)
# ssh/mosh sessions land in a persistent tmux session so agent runs survive disconnects
if [[ $- == *i* && -t 0 && -n "${SSH_CONNECTION:-}" && -z "${TMUX:-}" ]]; then
  exec tmux new-session -A -s main
fi
export PATH=$PATH:$HOME/.maestro/bin

# Omarchy shell defaults (aliases, starship, zoxide, fzf)
source ~/.config/zsh/omarchy.zsh

# OrbStack docker CLI
export PATH="$HOME/.orbstack/bin:$PATH"

autoload -Uz compinit && compinit   # daytona completion calls compdef
[[ -f "$HOME/.daytona.completion_script.zsh" ]] && source "$HOME/.daytona.completion_script.zsh"
