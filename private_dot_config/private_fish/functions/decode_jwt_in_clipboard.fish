function decode_jwt_in_clipboard
    fish_clipboard_paste | jq -R 'split(".") | {header: (.[0] | @base64d | fromjson), body: (.[1] | @base64d | fromjson), signature: .[2]}'
end
