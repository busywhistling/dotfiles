function deploy_hometube --description "Deploy hometube to hetzner and report when done"
  ssh hetzner "deploy_hometube"
  set -l code $status

  # Report through the terminal (OSC 9) rather than `osascript`: a banner from
  # osascript is attributed to Script Editor, so clicking it opened the editor.
  set -l message 'HomeTube deployed!'
  test $code -eq 0; or set message 'HomeTube deployment failed'
  if test -t 1
    printf '\e]9;%s\a' $message
  end

  return $code
end
