function delete_localonly_branches
  git switch develop
  git fetch --prune --all
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -D
end
