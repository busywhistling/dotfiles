if status is-interactive
  # Commands to run in interactive sessions can go here
  # if [ "$TERM" = "xterm-ghostty" ]
  #   # TODO: add
  #   # source ~/.config/fish/triage-screenshots.fish
  #   if test -z "$ZELLIJ_SESSION_NAME"
  #     zellij attach --create std options --session-serialization false
  #   end
  #   # eval (zellij setup --generate-auto-start fish | string collect)
  # end
  fish_vi_key_bindings
end

# if status is-interactive 
# 	and not set -q TMUX
# 	and [ "$TERM" = "xterm-kitty" ]
# 	# see https://stackoverflow.com/a/51922746
#   exec tmux new -A
# end

set icloud "/Users/paramjit/Library/Mobile Documents/com~apple~CloudDocs"

set -gx HOMEBREW_DOWNLOAD_CONCURRENCY "auto"
set -gx EDITOR nvim

set -l file (brew --prefix)/etc/profile.d/autojump.fish
test -s "$file"; and source $file

[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

set -gx GOPATH "$HOME/.local/go"

fish_ssh_agent

# Amp CLI
export PATH="/Users/paramjit/.amp/bin:$PATH"
