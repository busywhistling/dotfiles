function brave_cdp --description 'Start Brave with the CDP debugging port (9222) in the background, or quit it with --quit'
    argparse -n brave_cdp 'q/quit' 'h/help' -- $argv
    or return 1

    set -l app "/Applications/Brave Origin.app/Contents/MacOS/Brave Origin"
    set -l profile /Users/paramjit/.local/share/agent-browser-brave-profile
    set -l log $HOME/Library/Logs/brave_cdp.log
    set -l pattern 'MacOS/Brave Origin --remote-debugging-port=9222'
    set -l cdp_url http://127.0.0.1:9222/json/version

    if set -q _flag_help
        echo 'usage: brave_cdp [--quit]'
        echo '       brave_cdp          launch Brave with CDP on 127.0.0.1:9222 (backgrounded)'
        echo '       brave_cdp --quit   gracefully quit that instance, other Brave windows untouched'
        return 0
    end

    set -l pids (pgrep -f -- $pattern)

    if set -q _flag_quit
        if not set -q pids[1]
            echo 'brave_cdp: not running'
            return 0
        end

        kill -TERM $pids

        # SIGTERM is a clean quit: it flushes prefs and drops the profile lock.
        for i in (seq 50)
            pgrep -f -- $pattern >/dev/null; or begin
                # the cdp item polls every 10 min, so nudge it now
                sketchybar --reload >/dev/null 2>&1
                echo "brave_cdp: quit (pid $pids)"
                return 0
            end
            sleep 0.1
        end

        echo "brave_cdp: still running after 5s - try: pkill -KILL -f -- '$pattern'" >&2
        return 1
    end

    # Already up? Do nothing (a second launch would just hand off to the
    # existing instance and silently ignore the debug flag).
    if curl -fsS --max-time 1 $cdp_url >/dev/null 2>&1
        echo 'brave_cdp: already listening on 127.0.0.1:9222'
        return 0
    end

    # Process there but no endpoint: still starting up (or launched without the
    # debug flag) - launching again would just hand off and drop the flag.
    if set -q pids[1]
        echo "brave_cdp: already running (pid $pids), port not answering yet" >&2
        return 1
    end

    # nohup + disown: survives this shell/terminal going away.
    nohup "$app" \
        --remote-debugging-port=9222 \
        --user-data-dir=$profile \
        --no-first-run \
        --no-default-browser-check \
        >$log 2>&1 &
    disown

    # Wait for the endpoint before nudging the bar: reloading too early would
    # paint "down" and leave it stale until the next 10 min tick.
    for i in (seq 100)
        curl -fsS --max-time 1 $cdp_url >/dev/null 2>&1; and break
        sleep 0.1
    end

    # the cdp item polls every 10 min, so nudge it now
    sketchybar --reload >/dev/null 2>&1

    echo "brave_cdp: started in background (log: $log)"
end
