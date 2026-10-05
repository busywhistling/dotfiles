if type fnm > /dev/null && status is-interactive
  fnm env --shell fish --use-on-cd | source
  fnm completions --shell fish | source
  fnm default system

  # Exclude all subfolders of ~/Documents/4_gitclones from fnm's
  # auto-switching on cd: wrap the generated PWD hook and skip those paths.
  functions --copy _fnm_autoload_hook _fnm_autoload_hook_inner
  function _fnm_autoload_hook --on-variable PWD --description 'Change Node version on directory change'
    status --is-command-substitution; and return
    if string match -q -- "$HOME/Documents/4_gitclones/*" $PWD
      return
    end
    _fnm_autoload_hook_inner
  end
end

