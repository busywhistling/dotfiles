function sync_repos
  set path (pwd)

  printf "\nMaintaining 2_dev\n"
  cd "/Users/paramjit/Documents/2_dev"
  hub sync --color

  cd /Users/paramjit/Documents/4_github
  printf "\nSyncing downloaded repos\n"
  for repo in (ls)
    cd $repo
    printf "\nMaintaining $repo\n"
    hub sync --color
    cd ..
  end

  cd $path

  ls ~/Documents/4_github/ > ~/Documents/5_notes/gitclones.typ
end
