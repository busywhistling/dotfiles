function sync_repos
  set path (pwd)
  for repo in (fd -t d -d 1)
    printf "\nMaintaining $repo\n"
    cd $repo
    hub sync --color
    delete_localonly_branches
    cd ..
  end
  cd $path
end
