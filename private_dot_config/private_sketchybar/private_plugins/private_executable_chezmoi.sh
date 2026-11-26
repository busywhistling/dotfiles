#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Prefer the 1Password-backed wrapper; fall back to the plain binary if it
# is missing (e.g. during bootstrap). The wrapper reads the Keychain cache in
# a non-interactive context, so this poller never prompts.
CHEZMOI="${HOME}/.local/bin/chezmoi"
[ -x "$CHEZMOI" ] || CHEZMOI=chezmoi
STATUS=$("$CHEZMOI" status --exclude=scripts 2>/dev/null)

if [ -n "$STATUS" ]; then
  sketchybar --set "$NAME" label="chezmoi is out of sync" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=off
fi
