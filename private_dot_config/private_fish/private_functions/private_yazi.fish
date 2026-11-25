function yazi --description 'Launch yazi, hiding ~/Downloads while it is empty' --wraps=yazi
  set -l cfg ~/.config/yazi/yazi.toml
  set -l tag 'auto: yazi-downloads-exclude'
  set -l downloads $HOME/Downloads
  set -l marker "    \"$downloads\", # auto: yazi-downloads-exclude"

  # Declared at function scope on purpose: plain `set` inside an if/for block
  # only updates the nearest existing scope, so these survive `end`.
  # `empty` stays -1 (unknown) when Downloads cannot be read, so a permission
  # problem is never mistaken for "empty" and hides a folder that has files.
  set -l empty -1
  set -l present 0

  if test -r $cfg; and test -d $downloads
    grep -qF -- $tag $cfg; and set present 1

    # Fish globs skip dotfiles, so `~/Downloads/*` is exactly "entries that
    # count". An empty folder leaves the glob unexpanded, hence test -e.
    if test -r $downloads
      set empty 1
      for f in $downloads/*
        if test -e $f
          set empty 0
          break
        end
      end
    else
      echo 'yazi: cannot read' $downloads '- leaving the exclude list alone' >&2
    end
  end

  # The unique tag makes both the insert and the delete idempotent, and
  # mktemp + mv keeps yazi from ever reading a half-written config.
  # The exclude key is indented under [mgr], so the pattern allows whitespace.
  if test $empty = 1; and test $present = 0
    set -l tmp (mktemp (dirname $cfg)/.yazi.toml.XXXXXX)
    awk -v m="$marker" '!d && /^[[:space:]]*exclude[[:space:]]*=[[:space:]]*\[/ { print; print m; d = 1; next } { print }' $cfg >$tmp
    and command mv $tmp $cfg
    or command rm -f $tmp
  else if test $empty = 0; and test $present = 1
    set -l tmp (mktemp (dirname $cfg)/.yazi.toml.XXXXXX)
    awk '!/auto: yazi-downloads-exclude/' $cfg >$tmp
    and command mv $tmp $cfg
    or command rm -f $tmp
  end

  command yazi $argv
end
