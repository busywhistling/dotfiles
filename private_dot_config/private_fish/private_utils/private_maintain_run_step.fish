# Running a single step, and the schedule each step is held to.
#
# The policy lives here: how a step is presented, where its output goes, and
# when it counts as done. What the step actually does is in maintain_steps.

# Print the epoch of the last successful run, or nothing if it never ran.
function maintain_last_run -a cache name
  set -l file $cache/$name.timestamp
  test -f $file; or return 1
  set -l raw (string trim < $file 2>/dev/null)
  string match -qr '^\d+$' -- $raw; or return 1
  printf '%s' $raw
end

# An interval of 0 means "every run": no timestamp is recorded, so it is always
# due.
function maintain_due -a cache name interval
  test "$interval" -eq 0; and return 0
  set -l last (maintain_last_run $cache $name)
  if test -z "$last"
    return 0
  end
  test (math (date +%s) - $last) -ge $interval
end

# Run one step of the spec list: print a header, keep the output in the log,
# record the time on success.
#
# The third field of the spec chooses the presentation:
#
#   (none)  capture the output and animate a spinner in its place
#   stream  show the output as it arrives (progress bars, prompts)
#   tty     hand the terminal to the step itself (mole's own UI)
#
# Without a terminal to animate on, quiet steps stream too.
function maintain_run_step -a cache spec index total
  set -l name (string split -f 1 -- '|' $spec)
  set -l interval (string split -f 2 -- '|' $spec)
  set -l mode (string split -f 3 -- '|' $spec)
  set -l body maintain_step_$name
  set -l log $cache/$name.log
  set -l stop $cache/$name.stop

  printf '\n'
  if not functions -q $body
    maintain_ui_result fail $name 'not implemented'
    return 1
  end

  maintain_ui_title "maintain: $name ($index/$total)"
  set -l started (date +%s)
  set -l code 0

  if test "$mode" = tty
    maintain_ui_head $index $total $name
    $body
    set code $status
  else if test "$mode" = stream; or test "$__maintain_tty" = 0
    maintain_ui_head $index $total $name
    $body 2>&1 | tee $log
    set code $pipestatus[1]
    chmod 600 $log 2>/dev/null
    maintain_ui_break $log
  else
    # The step is a foreground job, so Ctrl-C stops it as usual. The spinner
    # is told to stop through a file, because it is a background job and would
    # otherwise outlive the run.
    rm -f $stop
    set -g __maintain_stop $stop
    command fish -c "source '$__fish_config_dir/utils/maintain_ui.fish'; maintain_ui_spin '$name' '$index' '$total' '$stop'" &
    set -l spinner $last_pid
    $body >$log 2>&1
    set code $status
    touch $stop
    test -n "$spinner"; and wait $spinner 2>/dev/null
    rm -f $stop
    set -g __maintain_stop
    chmod 600 $log 2>/dev/null
  end

  set -l detail (maintain_ui_short (math (date +%s) - $started))
  if test $code -eq 0
    maintain_ui_result ok $name $detail
  else if test $code -eq $MAINTAIN_SKIPPED
    maintain_ui_result skip $name 'nothing to do'
  else
    maintain_ui_result fail $name $detail
    maintain_ui_tail $log
  end

  if test $code -eq 0; and test "$interval" -ne 0
    date +%s > $cache/$name.timestamp
  end
  return $code
end
