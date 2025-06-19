function real_url
curl -s -L -o /dev/null -w '%{url_effective}\n' $argv
end
