function deploy_hometube
    ssh hetzner "deploy_hometube"; osascript -e 'display notification "It took so many minutes" with title "HomeTube deployed!" sound name "Glass"'
end
