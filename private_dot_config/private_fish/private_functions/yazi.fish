function yazi --description 'Launch yazi, hiding ~/Downloads while it is empty' --wraps=yazi
  set -l cfg ~/.config/yazi/yazi.toml
  set -l tag 'auto: yazi-downloads-exclude'
  set -l marker '  "/Users/paramjit/Downloads",  # auto: yazi-downloads-exclude'

  # Declared at function scope on purpose: `set -l` inside an if/for block is
  # block-scoped and would vanish at `end`.
  set -l empty 0
  set -l present 0

  # Fish globs skip dotfiles, so `~/Downloads/*` is exactly "entries that count".
  # An empty folder leaves the glob unexpanded, hence the test -e guard.
  if test -r $cfg; and test -r ~/Downloads
    set empty 1
    for f in ~/Downloads/*
      if test -e $f
        set empty 0
        break
      end
    end

    if grep -qF -- $tag $cfg
      set present 1
    end

    # The unique tag makes both the insert and the delete idempotent, and
    # mktemp + mv keeps yazi from ever reading a half-written config.
    if test $empty = 1; and test $present = 0
      set -l tmp (mktemp (dirname $cfg)/.yazi.toml.XXXXXX)
      awk -v m="$marker" '!d && /^exclude = \[/ { print; print m; d = 1; next } { print }' $cfg >$tmp
      and command mv $tmp $cfg
      or command rm -f $tmp
    else if test $empty = 0; and test $present = 1
      set -l tmp (mktemp (dirname $cfg)/.yazi.toml.XXXXXX)
      awk '!/auto: yazi-downloads-exclude/' $cfg >$tmp
      and command mv $tmp $cfg
      or command rm -f $tmp
    end
  end

  command yazi $argv
end
