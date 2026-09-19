function zellij --wraps=zellij
  if test (count $argv) -eq 0;
    zellij attach --create std options --session-serialization false
  else
    /opt/homebrew/bin/zellij $argv
  end
end
