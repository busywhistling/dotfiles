function git
  if test (count $argv) -gt 0; and [ "$argv[1]" = "checkout" ]
    echo "Don't use checkout, use switch instead."
  else
    set BREW_DIR (brew --prefix)
    $BREW_DIR/bin/git $argv
  end
end
