function note
  set inbox_location "/Users/paramjit/Documents/1 Notes/0 Inbox"
  set curr_month (date +"%Y-%m")
  set inboxfile "Journal-$curr_month.typ"
  
  cd $inbox_location
  if test -e $inboxfile
    # Attempting to reproduce the exact keystroke sequence with :normal and
    # literal <Esc> is trickier because escaping <Esc> on the shell can be
    # error-prone; the append()+startinsert approach is simpler and reliable.
    nvim -c "call append(0,['',''])" -c "normal! gg" -c "startinsert" $inboxfile
  else
    nvim $inboxfile
  end
end
