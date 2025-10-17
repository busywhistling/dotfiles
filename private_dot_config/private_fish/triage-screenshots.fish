set triage_last_notified ~/.local/share/triage_last_notified
set last_notified_hour (cat $triage_last_notified)
set hour_now (date +%H)

set show_notification false
if [ "$last_notified_hour" != "$hour_now" ]
  set show_notification true
end

if $show_notification
  set screenshots_count (count ~/Pictures/Screenshots/*)
  if [ $screenshots_count -gt 0 ]
    echo "There are $screenshots_count screenshots left to triage!"
  end
  
  set downloads_count (count ~/Downloads/*)
  if [ $downloads_count -gt 0 ]
    echo "There are $downloads_count downloads left to triage!"
  end

  echo $hour_now > $triage_last_notified
end
