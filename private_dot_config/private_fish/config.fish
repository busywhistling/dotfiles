if status is-interactive
  and [ "$TERM" = "xterm-kitty" ]
  # Commands to run in interactive sessions can go here
	fish_vi_key_bindings
end

# if status is-interactive 
# 	and not set -q TMUX
# 	and [ "$TERM" = "xterm-kitty" ]
# 	# see https://stackoverflow.com/a/51922746
#   exec tmux new -A
# end

source /Users/paramjit/.config/fish/conf.d/environment.fish
set icloud "/Users/paramjit/Library/Mobile Documents/com~apple~CloudDocs"
