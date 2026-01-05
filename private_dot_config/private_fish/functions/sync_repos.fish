function sync_repos
  set path (pwd)
  cd /Users/paramjit/Development/work
  for repo in (fd -t d -d 1)
    cd $repo
    hub sync
    delete_localonly_branches
    cd ..
  end
  cd $path
end
