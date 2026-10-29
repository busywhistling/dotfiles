#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting
#
# Same mechanics as chezmoi.sh, opposite polarity: the item only shows up
# while brave_cdp's DevTools endpoint is listening.

if curl -fsS --max-time 1 http://127.0.0.1:9222/json/version >/dev/null 2>&1; then
  sketchybar --set "$NAME" label="agent browser active" drawing=on
else
  sketchybar --set "$NAME" label="" drawing=off
fi
