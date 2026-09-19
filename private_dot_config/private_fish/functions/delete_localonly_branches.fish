function delete_localonly_branches
  set local_branches_gone_on_remote (git branch -vv | awk '/: gone]/{print ($1=="*" ? $2 : $1)}')
  set current_branch (git symbolic-ref --short HEAD)

  if contains $current_branch $local_branches_gone_on_remote
    if git show-ref --quiet --branches develop
      git switch develop
    else if git show-ref --quiet --branches main
      git switch main
    else if git show-ref --quiet --branches master
      git switch master
    end
  end

  # Prune unneeded branches
  git fetch --prune --all
  git branch -vv | awk '/: gone]/{print ($1=="*" ? $2 : $1)}' | xargs git branch -D
end
