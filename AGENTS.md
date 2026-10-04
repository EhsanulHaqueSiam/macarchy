# Working on macarchy

Read this before changing anything. It is written for coding agents but the
traps are real for humans too; most cost hours to find.

## One command

```sh
macarchy help       # every subcommand
macarchy doctor     # health: services, both configs, disjointness, macOS settings
macarchy verify     # functional regression suite, non-zero exit on failure
macarchy verify --windows   # plus live window checks (~20s; skips on a locked screen)
macarchy bindings --json   # every binding from both configs, machine readable
macarchy keys       # the human cheat sheet, generated from the live configs
macarchy reload     # restart aerospace, skhd, sketchybar, borders
```

Always finish a change with `macarchy verify`. It exercises the real bindings
through `aerospace trigger-binding`, so it catches "the file says so but nothing
is registered".

## The one rule

`~/.aerospace.toml` and `~/.config/skhd/skhdrc` are **strictly disjoint**:

- **AeroSpace** binds only native AeroSpace commands. No process spawn.
- **skhd** binds anything that runs a program, plus key synthesis.

A chord bound in both fires twice. `macarchy doctor` diffs the two files and
fails if they intersect. Never add a chord to one without checking the other.

## Layout

Every config in `$HOME` is a GNU stow symlink into this repo, so editing
`~/.aerospace.toml` edits `stow/aerospace/.aerospace.toml`. After adding or
renaming a file run `macarchy relink`. Before moving the repo run
`macarchy unlink`, or you leave 51 dangling symlinks behind.

## Traps

**AeroSpace callbacks need `USER`.** With `inherit-env-vars = false` a callback
gets only what `[exec.env-vars]` lists. `sketchybar --trigger` aborts with
`'env USER' not set!`, exits 1, and AeroSpace swallows it. The symptom is
maddeningly specific: switching to a workspace that *has* windows repaints fine
(`on-focus-changed` covers it) while switching to an *empty* one does nothing.
Debug callbacks with `env -i PATH=... /bin/bash -c '<the command>'` and read
stderr; AeroSpace never shows it. `aerospace list-exec-env-vars` prints what
callbacks actually receive.

**`bordersrc` must end by invoking `borders`.** JankyBorders execs that file when
started with no arguments. A file that never calls `borders` leaves it running on
stock defaults while `pgrep borders` looks perfectly healthy.

**Window opening is dwindled by `omarchy-mac-dwindle`**, wired as the LAST
`on-window-detected` entry. AeroSpace stops at the first matching rule, so
floating apps never reach it. That entry needs an explicit `if = 'true'`:
omitting `if` is a hard error, and AeroSpace rejects the WHOLE config on one
error while silently keeping the old one, so always check `aerospace
reload-config` output rather than assuming a change took.

**`split` is a no-op** while `enable-normalization-flatten-containers = true`.
AeroSpace says so itself. Use `join-with`, which is what `⌥⌘arrow` is bound to.

**A stale bar-hidden state file re-hides the bar on every reload.**
`bar-toggle.sh` persists to `~/.local/state/sketchybar/hidden` and sketchybarrc
replays it. Diagnose with `sketchybar --query <item> | jq .bounding_rects`: a
hidden bar parks items at origin `-9999,-9999`.

**A locked screen hides every window from AeroSpace.** Window tests on a locked
Mac fail in confusing ways (new windows never tile, `focus` finds nothing), so
check `ioreg -n Root -d1 -a | plutil -extract IOConsoleUsers.0.CGSSessionScreenIsLocked raw -o - -`
first; `verify --windows` does. Over ssh the accessibility API (System Events)
reports zero windows for every app even when unlocked: read geometry from
CoreGraphics instead (the `frame` helper in `macarchy`).

**Terminals open in one Ghostty.** `omarchy-mac-run` asks the running Ghostty for a
new window over AppleScript. Never go back to `open -na Ghostty`: every call
started a new Ghostty that outlived its window and grabbed ⌥S for its own quick terminal.

**Non-interactive ssh reads only `~/.zshenv`.** Tool environment that scripts
and agents need (Android SDK, `JAVA_HOME`, PATH) lives there, not in `.zshrc`.
T3 Code's device hub runs `avdmanager`/`emulator`/`adb` over plain ssh; with
them in `.zshrc` it reported `Failed to run avdmanager list avd`. After moving
env, kill the hub (`pkill -f expo-device-hub`) so T3 restarts it with the new one.

**Never restart skhd over ssh while the Mac is locked.** skhd aborts at start
when secure input is held (`secure keyboard entry is enabled by ... 'loginwindow'`),
so a restart from a locked or signed-out console takes the launcher half down until
someone unlocks. launchd retries every ~10s, so it heals itself on unlock. The same
lock makes `skhd -k` a no-op, so chords cannot be tested headlessly then; run the
script a binding calls instead. Check with `ioreg -l -w0 | grep SecureInputPID`.

**Per-app exceptions live in skhd blocks**, never AeroSpace (it has none):

```
alt + cmd - return [
  "t3 code (nightly)" ~
  * : ~/.local/bin/omarchy-mac-tmux  # Tmux
]
```

`~` passes the chord through to that app; names are the lowercased process
name. Keep `chord [`, `]` and `* : cmd  # desc` on their own lines: the doctor,
`macarchy bindings` and the ⌥K generator read the chord from `chord [` and the
command and description from the `*` line.

**skhd 0.3.9** has no `.shell` directive (it errors and ignores the rest of the
file) and no key-release event, so push-to-talk style bindings are impossible.
Errors go to `/tmp/skhd_$USER.err.log`; skhd exits 0 regardless.

**Do not run the pickers over ssh.** `omarchy-mac-menu-bar`, the wifi and
bluetooth bar clicks, and `omarchy-mac-transcode` open a blocking
`osascript choose from list`. Pass arguments instead, or you hang the session
until `pkill -x osascript`.

**Screen capture does not work over ssh** (`could not create image from
display`). macOS gates it behind a Screen Recording grant that cannot be given
to sshd from the command line. `macarchy docs` must run on the Mac itself.

**Raycast is invisible to the accessibility API**, so a working deeplink looks
identical to a broken one over ssh. Never conclude a Raycast binding is broken
from a headless test.

**`grep -c` prints `0` and exits `1`** when nothing matches, so the common
`$(grep -c x file || echo 0)` yields `"0\n0"` and every equality test against it
fails. This bit twice here. Assign, then default: `n=$(grep -c ...); n=${n:-0}`.

## Measuring

- `ps pcpu` is a **lifetime average**, not current load. It reported AeroSpace at
  19% right after a test sweep when it was idling at 0.5%. Diff `ps -o time=`
  across a sleep instead.
- `sketchybar --query <item>` puts the script under `.scripting.script`, not
  `.script`. Querying the wrong path returns null and reads like a lost script.
- Verifying a repaint needs a **dirty starting state**. Corrupt it first
  (`sketchybar --set space.1 label=XX`), then act, then re-query. Testing a
  repaint that is already correct proves nothing.

## Key mapping

Omarchy `SUPER` = `Option`, Omarchy/Hyprland `ALT` = `Command`, `CTRL` = `Control`.
So `SUPER + SHIFT + ALT + F` is `⌥⇧⌘F`. On a PC keyboard put SUPER on the Win key
with `omarchy-mac-keyboard-super`.

Because SUPER is `⌥`, app shortcuts on `⌥` chords collide. Before binding a new
chord, check the apps in use (T3 Code's live list: `~/.t3/userdata/keybindings.json`,
where `mod` is `⌘` and `alt` is `⌥`). README's "Apps that bind ⌥ chords" has the policy.

Coverage against Omarchy's own `default/hypr/bindings/*.lua` is 144/152 mappable
bindings: 7 are impossible on macOS (listed in README.md) and Obsidian is unbound on purpose; do not
try to "fix" them without checking there first.
