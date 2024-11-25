# Fewer than 47 columns will probably work. Haven't tried it.
typeset -gr __ryz9k_wizard_columns=47
# The bottleneck is ask_tails with nerd fonts. Everything else works fine with 12 lines.
typeset -gr __ryz9k_wizard_lines=14
typeset -gr __ryz9k_zd=${ZDOTDIR:-$HOME}
typeset -gr __ryz9k_zd_u=${${${(q)__ryz9k_zd}/#(#b)${(q)HOME}(|\/*)/'~'$match[1]}//\%/%%}
typeset -gr __ryz9k_zshrc=${${:-$__ryz9k_zd/.zshrc}:A}
typeset -gr __ryz9k_zshrc_u=$__ryz9k_zd_u/.zshrc
typeset -gr __ryz9k_root_dir_u=${${${(q)__ryz9k_root_dir}/#(#b)${(q)HOME}(|\/*)/'~'$match[1]}//\%/%%}

function _ryz9k_can_configure() {
  [[ $1 == '-q' ]] && local -i q=1 || local -i q=0
  function $0_error() {
    (( q )) || print -rP "%1F[ERROR]%f %Bryz10k configure%b: $1" >&2
  }
  typeset -g __ryz9k_cfg_path_o=${RYZSHRC9K_CONFIG_FILE:=${ZDOTDIR:-~}/.ryz10k.zsh}
  typeset -g __ryz9k_cfg_basename=${__ryz9k_cfg_path_o:t}
  typeset -g __ryz9k_cfg_path=${__ryz9k_cfg_path_o:A}
  typeset -g __ryz9k_cfg_path_u=${${${(q)__ryz9k_cfg_path_o}/#(#b)${(q)HOME}(|\/*)/'~'$match[1]}//\%/%%}
  {
    [[ -e $__ryz9k_zd ]]         || { $0_error "$__ryz9k_zd_u does not exist";       return 1 }
    [[ -d $__ryz9k_zd ]]         || { $0_error "$__ryz9k_zd_u is not a directory";   return 1 }
    [[ ! -d $__ryz9k_cfg_path ]] || { $0_error "$__ryz9k_cfg_path_u is a directory"; return 1 }
    [[ ! -d $__ryz9k_zshrc ]]    || { $0_error "$__ryz9k_zshrc_u is a directory";    return 1 }

    local dir=${__ryz9k_cfg_path:h}
    while [[ ! -e $dir && $dir != ${dir:h} ]]; do dir=${dir:h}; done
    if [[ ! -d $dir ]]; then
      $0_error "cannot create $__ryz9k_cfg_path_u because ${dir//\%/%%} is not a directory"
      return 1
    fi
    if [[ ! -w $dir ]]; then
      $0_error "cannot create $__ryz9k_cfg_path_u because ${dir//\%/%%} is readonly"
      return 1
    fi

    [[ ! -e $__ryz9k_cfg_path || -f $__ryz9k_cfg_path || -h $__ryz9k_cfg_path ]] || {
      $0_error "$__ryz9k_cfg_path_u is a special file"
      return 1
    }
    [[ ! -e $__ryz9k_zshrc || -f $__ryz9k_zshrc || -h $__ryz9k_zshrc ]]          || {
      $0_error "$__ryz9k_zshrc_u a special file"
      return 1
    }
    [[ ! -e $__ryz9k_zshrc || -r $__ryz9k_zshrc ]]                             || {
      $0_error "$__ryz9k_zshrc_u is not readable"
      return 1
    }
    local style
    for style in lean lean-8colors classic rainbow pure; do
      [[ -r $__ryz9k_root_dir/config/ryz10k-$style.zsh ]]                      || {
        $0_error "$__ryz9k_root_dir_u/config/ryz10k-$style.zsh is not readable"
        return 1
      }
    done

    (( LINES >= __ryz9k_wizard_lines && COLUMNS >= __ryz9k_wizard_columns ))   || {
      $0_error "terminal size too small; must be at least $__ryz9k_wizard_columns columns by $__ryz9k_wizard_lines lines"
      return 1
    }
    [[ -t 0 && -t 1 ]]                                                     || {
      $0_error "no TTY"
      return 2
    }
    return 0
  } always {
    unfunction $0_error
  }
}

function ryz9k_configure() {
  eval "$__ryz9k_intro"
  _ryz9k_can_configure || return
  (
    set -- -f
    builtin source $__ryz9k_root_dir/internal/wizard.zsh
  )
  local ret=$?
  case $ret in
    0)  builtin source $__ryz9k_cfg_path; _ryz9k__force_must_init=1;;
    69) return 0;;
    *)  return $ret;;
  esac
}
