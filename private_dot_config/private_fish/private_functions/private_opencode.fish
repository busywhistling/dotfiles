function opencode --wraps opencode
  nono run --silent --allow-cwd --profile opencode -- $HOMEBREW_PREFIX/bin/opencode $argv
end
