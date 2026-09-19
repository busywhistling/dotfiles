function ls
  if test "$TERM" = "xterm-kitty"
    eza --group-directories-first --hyperlink $argv
  else
    eza --group-directories-first $argv
  end
end
