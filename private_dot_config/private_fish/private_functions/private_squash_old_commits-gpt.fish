#!/usr/bin/env fish

# Usage:
#   ./squash-old.fish              # defaults to "3 months"
#   ./squash-old.fish "6 months"
#   ./squash-old.fish 90 days

set -l squash_message "init: squashed history"
set -l period "3 months"

if test (count $argv) -gt 0
  set period (string join " " -- $argv)
end

set -l cutoff_text "$period"

if not string match --quiet --regex '(^|[[:space:]])ago[[:space:]]*$' -- $cutoff_text
  set cutoff_text "$cutoff_text ago"
end

if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
  echo "error: not inside a Git work tree" >&2
  exit 1
end

set -l dirty_status (git status --porcelain)

if test (count $dirty_status) -ne 0
  echo "error: working tree is not clean; commit or stash changes first" >&2
  exit 1
end

set -l cutoff_line (git rev-parse --since="$cutoff_text" 2>/dev/null)
set -l parse_status $status

if test $parse_status -ne 0
  echo "error: Git could not parse period: $period" >&2
  exit 1
end

set -l cutoff_ts (string replace -- '--max-age=' '' $cutoff_line)

if not string match --quiet --regex '^[0-9]+$' -- $cutoff_ts
  echo "error: unexpected cutoff timestamp: $cutoff_line" >&2
  exit 1
end

set -l commits (git rev-list --reverse --topo-order HEAD)
set -l total_count (count $commits)
set -l old_count 0
set -l last_old_commit
set -l seen_new_commit 0

for commit in $commits
  set -l author_ts (git show -s --format=%at $commit)

  if test $author_ts -lt $cutoff_ts
    if test $seen_new_commit -eq 1
      echo "error: commits authored before '$cutoff_text' do not form a contiguous initial history prefix" >&2
      echo "error: refusing to rewrite; commit $commit is old but appears after a newer commit" >&2
      exit 1
    end

    set last_old_commit $commit
    set old_count (math $old_count + 1)
  else
    set seen_new_commit 1
  end
end

if test $old_count -eq 0
  echo "no commits authored before '$cutoff_text'; nothing to squash"
  exit 0
end

set -l backup_ref "backup/pre-squash-"(date "+%Y%m%d-%H%M%S")

if not git branch $backup_ref HEAD
  echo "error: could not create backup branch" >&2
  exit 1
end

set -l author_name (git show -s --format=%an $last_old_commit)
set -l author_email (git show -s --format=%ae $last_old_commit)
set -l author_date (git show -s --format=%aI $last_old_commit)

set -l new_root_commit (env \
  GIT_AUTHOR_NAME="$author_name" \
  GIT_AUTHOR_EMAIL="$author_email" \
  GIT_AUTHOR_DATE="$author_date" \
  GIT_COMMITTER_NAME="$author_name" \
  GIT_COMMITTER_EMAIL="$author_email" \
  GIT_COMMITTER_DATE="$author_date" \
  git commit-tree "$last_old_commit^{tree}" -m "$squash_message")

if test $status -ne 0
  echo "error: could not create squashed initial commit" >&2
  exit 1
end

if test $old_count -eq $total_count
  if not git reset --hard $new_root_commit
    echo "error: reset failed; backup branch is $backup_ref" >&2
    exit 1
  end
else
  if not git rebase --rebase-merges --onto $new_root_commit $last_old_commit
    echo "error: rebase failed; backup branch is $backup_ref" >&2
    echo "hint: after resolving, run 'git rebase --continue', or abort with 'git rebase --abort'" >&2
    exit 1
  end
end

echo "done"
echo "squashed $old_count commit(s) authored before '$cutoff_text'"
echo "backup branch: $backup_ref"
