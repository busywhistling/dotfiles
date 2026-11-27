function opencode
  # macOS: keep the machine awake while OpenCode runs.
  # Linux (the Hetzner box): brew's opencode-v2 is on PATH.
  if test (uname) = Darwin
    caffeinate -i /opt/homebrew/bin/opencode $argv
  else
    command opencode $argv
  end
end
