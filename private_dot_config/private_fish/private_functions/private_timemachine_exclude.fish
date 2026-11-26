function timemachine_exclude
  echo "Ignoring directories from time machine backup"
  fd "^\.yarn\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    --exclude node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^\.venv\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^node_modules\$" ~/Documents \
    --unrestricted --type d --prune -E .next -E 3_github \
    -x sudo tmutil addexclusion -p {}
  fd "^\.git\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^\.next\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^\.turbo\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^\.cargo\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 
  fd "^target\$" ~/Documents \
    --unrestricted --type d --prune -E 3_github -E node_modules \
    -x sudo tmutil addexclusion -p {} 

  sudo tmutil addexclusion -p /Users/paramjit/Documents/3_github
  sudo tmutil addexclusion -p /Users/paramjit/.local/share
  sudo tmutil addexclusion -p /Users/paramjit/.agent-browser
  sudo tmutil addexclusion -p /Users/paramjit/Pictures
  sudo tmutil addexclusion -p /Users/paramjit/Movies
  sudo tmutil addexclusion -p /Users/paramjit/Music
  sudo tmutil addexclusion -p /Users/paramjit/Library/Containers/com.utmapp.UTM/
  sudo tmutil addexclusion -p /Users/paramjit/Library/Containers/com.utmapp.QEMUHelper/
  sudo tmutil addexclusion -p /Users/paramjit/Documents/Zwift/

  sudo tmutil addexclusion -p /Users/paramjit/.lima/_disks
  sudo tmutil addexclusion -p /Users/paramjit/.android
  sudo tmutil addexclusion -p /Users/paramjit/.cache
  sudo tmutil addexclusion -p /Users/paramjit/.nono
  sudo tmutil addexclusion -p /Users/paramjit/.npm
  sudo tmutil addexclusion -p /Users/paramjit/.pulumi
  sudo tmutil addexclusion -p /Users/paramjit/.rustup
  sudo tmutil addexclusion -p /Users/paramjit/.thumbnails
  sudo tmutil addexclusion -p /Users/paramjit/.Trash
  sudo tmutil addexclusion -p /Users/paramjit/Library/Application\ Support/com.apple.container
end
