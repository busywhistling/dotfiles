function python --wraps=python3
  if test (count $argv) -eq 0
    bpython
  else
    $HOMEBREW_PREFIX/bin/python3 $argv
  end
end
