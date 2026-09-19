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

set -l file (brew --prefix)/etc/profile.d/autojump.fish
test -s "$file"; and source $file

[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

set -gx GOPATH "$HOME/.local/go"

fish_ssh_agent


# set -gx UV_MALWARE_CHECK 1
set -gx HOMEBREW_REQUIRE_TAP_TRUST 1
set -gx HOMEBREW_NO_ANALYTICS 1


set -gx PATH "/Users/paramjit/.local/state/fnm_multishells/63708_1779105837510/bin" $PATH;
set -gx FNM_MULTISHELL_PATH "/Users/paramjit/.local/state/fnm_multishells/63708_1779105837510";
set -gx FNM_VERSION_FILE_STRATEGY "local";
set -gx FNM_DIR "/Users/paramjit/Library/Application Support/fnm";
set -gx FNM_LOGLEVEL "info";
set -gx FNM_NODE_DIST_MIRROR "https://nodejs.org/dist";
set -gx FNM_COREPACK_ENABLED "false";
set -gx FNM_RESOLVE_ENGINES "true";
set -gx FNM_ARCH "arm64";
