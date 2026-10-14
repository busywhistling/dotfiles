function brewdump --description 'Generate a Brewfile with only explicitly installed packages (taps, brew leaves, casks)'
    # Usage: brewdump [outfile]
    #   (default: ~/.config/Brewfile-(hostname -s))

    if test (count $argv) -ge 1
        set out $argv[1]
    else
        set out $HOME/.config/Brewfile-(hostname -s)
    end

    set tmp (mktemp)
    set lv (mktemp)

    begin
        brew info --json=v2 --installed > $tmp
        brew leaves --installed-on-request > $lv

        printf '#!/usr/bin/env brewfile\n'
        printf '# Top-level (explicitly installed) packages only.\n'

        printf '# Taps\n'
        jq -r '([.formulae[].tap, .casks[].tap] | unique) - ["homebrew/core", "homebrew/cask"] | sort[] | "tap \"\(.)\""' $tmp

        printf '\n# Formulae (top-level only)\n'
        jq -r --rawfile lv $lv \
            '[$lv | split("\n")[] | select(length > 0)] as $leaves
             | .formulae[]
             | select(.name as $n | $leaves | index($n))
             | (if .full_name == .name then .name else .full_name end) as $n
             | "brew \"\($n)\"  # \(.desc)"' $tmp | sort

        printf '\n# Casks\n'
        jq -r '.casks[] | (.full_token // .token) as $n | "cask \"\($n)\"  # \(.desc // "")"' $tmp | sort
    end > $out

    rm -f $tmp $lv

    set lines (cat $out | wc -l | string trim)
    echo "Written: $out ($lines lines)"
end
