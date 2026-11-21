#!/usr/bin/env fish
# Mirror the launch agents managed in ~/.config/LaunchAgents into
# ~/Library/LaunchAgents.
#
# chezmoi never writes to ~/Library directly (the whole directory is in
# .chezmoiignore), so ~/.config/LaunchAgents is the source of truth and this
# script installs it after every apply. Files that are already identical are
# left untouched.
#
# Reloading an agent after it changes is left to launchd/the user, e.g.
#   launchctl bootout   gui/(id -u)/dev.paramjit.push-screenshots
#   launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/dev.paramjit.push-screenshots.plist
if test (uname -s) != Darwin
  exit 0
end

set -l src $HOME/.config/LaunchAgents
set -l dst $HOME/Library/LaunchAgents

test -d $src; or exit 0
mkdir -p $dst

for agent in $src/*.plist
  set -l name (basename $agent)
  cmp -s $agent $dst/$name; and continue
  cp $agent $dst/$name
  printf 'launchagent: installed %s\n' $dst/$name
end
