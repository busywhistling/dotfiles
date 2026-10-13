function ca
    cd; chezmoi add --quiet * (string match -v .ssh .*); chezmoi cd
end
