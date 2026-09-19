#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

STATUS=$(chezmoi status 2>/dev/null)

if [ -n "$STATUS" ]; then
  sketchybar --set "$NAME" label="chezmoi is out of sync" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=off
fi
