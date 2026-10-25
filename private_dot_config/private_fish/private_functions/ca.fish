function ca
    cd; or return

    # Files managed as templates: re-adding them would prompt to remove the
    # template attribute, so skip them and add their siblings instead.
    set -l templates (chezmoi managed --include templates)

    set -l ancestors
    for template in $templates
        set -l dir (path dirname $template)
        while test $dir != .
            set -a ancestors $dir
            set dir (path dirname $dir)
        end
    end
    set -l ancestors (string match -v -r '^$' $ancestors | sort -u)

    set -l others
    for entry in (command ls -A)
        contains -- $entry $templates; and continue
        contains -- $entry $ancestors; and continue
        set -a others $entry
    end
    if set -q others[1]
        chezmoi add --quiet $others
    end

    # Add the contents of the directories that hold templates, minus the
    # templates themselves and minus the directories leading further down.
    for dir in $ancestors
        test -d $dir; or continue
        set -l siblings
        for entry in (command ls -A $dir)
            set -l path $dir/$entry
            contains -- $path $templates; and continue
            contains -- $path $ancestors; and continue
            set -a siblings $path
        end
        if set -q siblings[1]
            chezmoi add --quiet $siblings
        end
    end

    chezmoi cd
end
