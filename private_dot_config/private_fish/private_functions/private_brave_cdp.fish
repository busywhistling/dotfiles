function brave_cdp --description 'Start Brave with the CDP debugging port (9222) in the background'
    set -l app "/Applications/Brave Origin.app/Contents/MacOS/Brave Origin"
    set -l profile /Users/paramjit/.local/share/agent-browser-brave-profile
    set -l log /Users/paramjit/Library/Logs/brave_cdp.log

    # Already up? Do nothing (a second launch would just hand off to the
    # existing instance and silently ignore the debug flag).
    if curl -fsS --max-time 1 http://127.0.0.1:9222/json/version >/dev/null 2>&1
        echo "brave_cdp: already listening on 127.0.0.1:9222"
        return 0
    end

    # nohup + disown: survives this shell/terminal going away.
    nohup "$app" \
        --remote-debugging-port=9222 \
        --user-data-dir=$profile \
        --no-first-run \
        --no-default-browser-check \
        >$log 2>&1 &
    disown

    echo "brave_cdp: started in background (log: $log)"
end
