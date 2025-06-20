function backup_homebrew
    # backup your package list into the file: ~/Brewfile
    brew bundle dump --file=~/.config/Brewfile --force
end
