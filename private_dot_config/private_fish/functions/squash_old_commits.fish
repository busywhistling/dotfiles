function squash_old_commits
  set months (math (string match -r '^\d+' -- "$argv[1]") 2>/dev/null; or echo 3)

  if test (uname) = Darwin
    set cutoff (date -v-{$months}m +%Y-%m-%d)
  else
    set cutoff (date -d "$months months ago" +%Y-%m-%d)
  end

  set last_old (git log --format="%ad %h" --date=format:"%Y-%m-%d" | awk -v cutoff=$cutoff '$1 <= cutoff {print $2; exit}')

  if test -z "$last_old"
    echo "No commits with author date older than $months months ($cutoff) — nothing to squash."
    return 0
  end

  echo "Cutoff date: $cutoff"
  echo "Squashing all commits up to: "(git log -1 --format='%h %s (authored: %ad)' --date=format:'%Y-%m-%d' $last_old)
  echo ""
  echo "Recent commits that will be kept:"
  git log --format="%ad %h %s" --date=format:"%Y-%m-%d" | awk -v cutoff=$cutoff '$1 > cutoff {print "  " $0}' | head -20
  echo ""

  read --prompt-str "Continue? [y/N] " confirm
  if test "$confirm" != y -a "$confirm" != Y
    echo "Aborted."
    return 1
  end

  set editor_script "sed -i '2,/$last_old/s/^pick/squash/'"
  if test (uname) = Darwin
    set editor_script "sed -i '' '2,/$last_old/s/^pick/squash/'"
  end

  GIT_SEQUENCE_EDITOR=$editor_script git rebase -i --root
end
