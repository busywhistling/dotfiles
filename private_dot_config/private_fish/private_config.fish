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

set -gx HOMEBREW_DOWNLOAD_CONCURRENCY "auto"
set -gx EDITOR nvim
set -gx HOMEBREW_PREFIX (brew --prefix)

set -l file $HOMEBREW_PREFIX/etc/profile.d/autojump.fish
test -s "$file"; and source $file

[ -f $HOMEBREW_PREFIX/share/autojump/autojump.fish ]; and source $HOMEBREW_PREFIX/share/autojump/autojump.fish

set -gx GOPATH "$HOME/.local/go"

fish_ssh_agent

# set -gx UV_MALWARE_CHECK 1
set -gx HOMEBREW_REQUIRE_TAP_TRUST 1
set -gx HOMEBREW_NO_ANALYTICS 1

set -gx PYTHON_HISTORY ~/.local/share/python/python_history

set -gx _ZO_EXCLUDE_DIRS "$HOME"
zoxide init fish | source


if test (hostname) = macbook
  source /Users/paramjit/.config/op/plugins.sh
end

set -gx AWS_CONFIG_FILE ~/.config/aws/config
# AWS_SHARED_CREDENTIALS_FILE

set -gx NPM_CONFIG_USERCONFIG ~/.config/npmrc

# Hermes Agent command
fish_add_path "$HOME/.local/bin"
