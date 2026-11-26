# Everything `maintain` prints: the markers, the step lines, the spinner, the
# summary and the notification. Nothing here runs a step or reads the schedule,
# so the output can change without touching how the run works.

# Decide once per run whether colour and animation are available. Called from
# `maintain` before anything is printed: the marker helpers run inside command
# substitutions, where testing the tty is not possible.
function maintain_ui_init
  set -g __maintain_colour 0
  set -g __maintain_tty 0
  if test -t 1
    set -g __maintain_tty 1
    if not set -q NO_COLOR
      set -g __maintain_colour 1
    end
  end
end

function maintain_ui_marker -a kind
  set -l glyph '▸'
  set -l code 34
  switch $kind
    case ok
      set glyph '✓'
      set code 32
    case fail
      set glyph '✗'
      set code 31
    case skip
      set glyph '↷'
      set code 90
  end
  if test "$__maintain_colour" = 1
    printf '\e[%sm%s\e[0m' $code $glyph
  else
    printf '%s' $glyph
  end
end

# A step that streams its output needs a header first; a quiet step's spinner
# already showed the same line.
function maintain_ui_head -a index total name
  maintain_ui_marker run
  if test "$__maintain_colour" = 1
    printf ' \e[90m[%s/%s]\e[0m \e[1m%s\e[0m\n' $index $total $name
  else
    printf ' [%s/%s] %s\n' $index $total $name
  end
end

# The result repeats the step's position, because a quiet step's spinner (and
# its [n/total]) is erased when the line is replaced.
function maintain_ui_result -a kind index total name detail
  set -l padded (string pad -w 26 --right -- $name)
  maintain_ui_marker $kind
  if test "$__maintain_colour" = 1
    printf ' \e[90m[%s/%s]\e[0m %s \e[90m%s\e[0m\n' $index $total $padded $detail
  else
    printf ' [%s/%s] %s %s\n' $index $total $padded $detail
  end
end

# Pass a streamed step's output through, indented to line up with the step
# lines. rsync and mbsync rewrite the same line with a carriage return, so
# only the final state of each line is kept: the log reads as one line per
# file instead of hundreds of frames.
function maintain_ui_indent
  while true
    set -l line
    if read -l line
      printf '  %s\n' (string replace -r '.*\r\s*' '' -- $line)
    else
      test -n "$line"; and printf '  %s\n' (string replace -r '.*\r\s*' '' -- $line)
      return 0
    end
  end
end

# Show the end of a failed step's log, so the reason is on screen without
# opening anything.
function maintain_ui_tail -a log
  test -s $log; or return 0
  tail -n 10 $log | string replace -r '^' '    '
end

# A step's output usually ends with a newline, but progress bars and prompts
# do not; without this the next line would start mid-line.
function maintain_ui_break -a log
  test -s $log; or return 0
  set -l last (tail -c 1 $log 2>/dev/null | od -An -c | string trim)
  test "$last" = '\n'; or printf '\n'
end

# The spinner runs as its own process so it can animate while the step runs.
# It stops when the parent creates the stop file: after the step, or from the
# interrupt handler.
function maintain_ui_spin -a name index total stop
  set -l frames (string split '' '⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏')
  set -l colour 0
  if test -t 1; and not set -q NO_COLOR
    set colour 1
  end
  set -l started (date +%s)
  set -l i 0
  while not test -f $stop
    set -l frame $frames[(math "$i % 10 + 1")]
    set -l secs (math (date +%s) - $started)
    if test $colour -eq 1
      printf '\r\e[2K\e[36m%s\e[0m \e[90m[%s/%s]\e[0m \e[1m%s\e[0m \e[90m%s\e[0m' $frame $index $total $name (maintain_ui_short $secs)
    else
      printf '\r\e[2K%s [%s/%s] %s %s' $frame $index $total $name (maintain_ui_short $secs)
    end
    set i (math $i + 1)
    sleep 0.2
  end
  printf '\r\e[2K'
end

# A window title is the only progress indicator left once the terminal is
# scrolled away or the tab is in the background.
function maintain_ui_title -a text
  test -t 1; or return 0
  printf '\e]0;%s\e\\' $text
end

function maintain_ui_notify -a summary
  set -q MAINTAIN_NOTIFY; and test "$MAINTAIN_NOTIFY" = 0; and return 0
  test -t 1; or return 0
  # OSC 9 asks the terminal itself to raise the notification, so it is
  # attributed to the terminal and a click only brings the window forward.
  # `osascript -e 'display notification'` posts as Script Editor instead, and
  # clicking that notification launches Script Editor.
  printf '\e]9;%s\a' $summary
end

function maintain_ui_short -a seconds
  set -l s (math "floor($seconds)")
  if test $s -lt 60
    printf '%ss' $s
  else if test $s -lt 3600
    printf '%sm' (math "floor($s / 60)")
  else if test $s -lt 86400
    set -l h (math "floor($s / 3600)")
    set -l m (math "floor(($s % 3600) / 60)")
    if test $m -eq 0
      printf '%sh' $h
    else
      printf '%sh%02dm' $h $m
    end
  else
    set -l d (math "floor($s / 86400)")
    set -l h (math "floor(($s % 86400) / 3600)")
    if test $h -eq 0
      printf '%sd' $d
    else
      printf '%sd%02dh' $d $h
    end
  end
end

# The closing report. Each step already printed its own result line; this is
# what still matters once the terminal has scrolled away.
#
# The three name lists arrive space-separated, since fish flattens lists into
# the argument vector anyway.
function maintain_ui_summary -a spent ran failed waiting excluded
  set -l failed_names
  if test -n "$failed"
    set failed_names (string split ' ' -- $failed)
  end

  set -l noun steps
  test "$ran" -eq 1; and set noun step
  set -l head 'maintain: '(maintain_ui_short $spent)' · '$ran' '$noun
  if set -q failed_names[1]
    set head "$head · "(count $failed_names)' failed'
  else
    set head "$head · all good"
  end
  printf '\n%s\n' $head

  if set -q failed_names[1]
    printf '  %s %s — ~/.cache/maintain/<step>.log\n' (maintain_ui_marker fail) (string join ' ' $failed_names)
  end
  if test -n "$excluded"
    printf '  %s not selected: %s\n' (maintain_ui_marker skip) $excluded
  else if test -n "$waiting"
    printf '  %s not due: %s\n' (maintain_ui_marker skip) $waiting
  end

  # A long run, or any failure, is worth a notification: the terminal is
  # usually not in sight by then.
  if test "$spent" -ge 300; or set -q failed_names[1]
    maintain_ui_notify $head
  end
end

# The schedule as a table.
function maintain_ui_status -a cache
  set -l now (date +%s)
  printf '%s %s %s\n' \
    (string pad -w 30 --right -- 'step') \
    (string pad -w 12 --right -- 'last run') \
    'next run'
  for spec in (maintain_steps)
    set -l name (string split -f 1 -- '|' $spec)
    set -l interval (string split -f 2 -- '|' $spec)
    set -l last (maintain_last_run $cache $name)
    set -l when '-'
    set -l next 'every run'
    if test "$interval" -ne 0
      if test -n "$last"
        set -l age (math $now - $last)
        set when (maintain_ui_short $age)' ago'
        if test $age -ge $interval
          set next now
        else
          set next 'in '(maintain_ui_short (math $interval - $age))
        end
      else
        set when never
        set next now
      end
    end
    set -l mark ' '
    if test $next = now
      set mark '*'
    end
    printf '%s %s %s %s\n' $mark \
      (string pad -w 30 --right -- $name) \
      (string pad -w 12 --right -- $when) \
      $next
  end
end

# What the next run would execute.
function maintain_ui_plan -a cache
  set -l due
  set -l idle
  for spec in (maintain_steps)
    set -l name (string split -f 1 -- '|' $spec)
    set -l interval (string split -f 2 -- '|' $spec)
    if maintain_due $cache $name $interval
      set -a due $name
    else
      set -a idle $name
    end
  end
  if set -q due[1]
    printf 'due (%s): %s\n' (count $due) (string join ' ' $due)
  else
    printf 'nothing is due\n'
  end
  if set -q idle[1]
    printf 'not due (%s): %s\n' (count $idle) (string join ' ' $idle)
  end
end
