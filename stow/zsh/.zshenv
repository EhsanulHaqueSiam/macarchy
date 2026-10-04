# Sourced by every zsh, including non-interactive `ssh mac 'cmd'` runs (agents, scripts).
# Same tool PATH as an interactive shell: ~/.local/bin, mise shims, OrbStack docker, Homebrew.
# Interactive shells still get `mise activate` from .zshrc, which takes precedence over the shims.
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$HOME/.orbstack/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"   # psql (keg-only); e2e/helpers/db.ts shells out to it
# Android SDK (installed via sdkmanager, no Studio wizard) and Java for it and maestro.
# Here, not .zshrc: T3 Code's device hub runs `avdmanager`/`emulator`/`adb` over plain ssh.
# (Android Studio's bundled JBR hangs from a shell, hence Homebrew's openjdk@21.)
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$HOME/.maestro/bin:$PATH"
