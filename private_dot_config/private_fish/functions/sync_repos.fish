function sync_repos
  set path (pwd)
  cd "/Users/paramjit/Documents/5 Work dev"
  for repo in (fd -t d -d 1)
    cd $repo
    printf "\nMaintaining $repo\n"
    hub sync
    delete_localonly_branches
    cd ..
  end
  cd $path
end
