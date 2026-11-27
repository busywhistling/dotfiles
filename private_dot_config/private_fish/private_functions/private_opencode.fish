function opencode
  # macOS: keep the machine awake while OpenCode runs.
  # Linux (the Hetzner box): run the user-installed v2 binary, because brew only
  # ships v1 there and its DB has been migrated.
  if test (uname) = Darwin
    caffeinate -i /opt/homebrew/bin/opencode $argv
  else
    command $HOME/.opencode/bin/opencode $argv
  end
end
