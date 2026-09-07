# Working on macarchy

Read this before changing anything. It is written for coding agents but the
traps are real for humans too; most cost hours to find.

## One command

```sh
macarchy help       # every subcommand
macarchy doctor     # health: services, both configs, disjointness, macOS settings
macarchy verify     # functional regression suite, non-zero exit on failure
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

**`split` is a no-op** while `enable-normalization-flatten-containers = true`.
AeroSpace says so itself. Use `join-with`, which is what `⌥⌘arrow` is bound to.

**A stale bar-hidden state file re-hides the bar on every reload.**
`bar-toggle.sh` persists to `~/.local/state/sketchybar/hidden` and sketchybarrc
replays it. Diagnose with `sketchybar --query <item> | jq .bounding_rects`: a
hidden bar parks items at origin `-9999,-9999`.

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

Coverage against Omarchy's own `default/hypr/bindings/*.lua` is 142/149 mappable
bindings. The 7 gaps are impossible on macOS and are listed in README.md; do not
try to "fix" them without checking there first.
