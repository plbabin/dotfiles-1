############ Portable .zshrc ###############
# Zachary Voase <z@zacharyvoase.com>       #
# https://github.com/zacharyvoase/dotfiles #
############################################

  function glob-exists () {
    # glob-exists "<GLOB>"
    # Test to see if a glob matches anything.
    # Example: glob-exists "~/.ssh/*.pub"
    [[ -n `zsh -G -c 'echo ${~1}'` ]];
  }

  function tty-of-pid () {
    echo /dev/tty`ps -p "$1" -o tt | tail -n 1`
  }

#=========
#  PATHS
#=========

  export PLATFORM=`uname -s`

  if [ $PLATFORM = Darwin ]; then
    dev=~/Development
    desk=~/Desktop

    USER_PATH=~/Development/bin
    PYTHON_PATH=/Library/Frameworks/Python.framework/Versions/Current/bin

    export PATH=$USER_PATH:$PYTHON_PATH:$PATH
  elif [ $PLATFORM = Linux ]; then
    if glob-exists "~/.ssh/*.pub" && which keychain >/dev/null 2>&1; then
      eval `ls ~/.ssh/*.pub | sed 's/\.pub//' | xargs keychain --eval`
    fi
  fi

  mkdir -p ~/.zsh/cache

#=======================
#  LANGUAGES/TIMEZONES
#=======================

  export LC_ALL="en_US.UTF-8"
  export LANG="en_US.UTF-8"
  export LC_CTYPE=C
  export TZ='GMT'

#===========
#  OPTIONS
#===========

  #------------------------
  #  Changing Directories
  #------------------------

    setopt   AUTO_CD # If a command isn't found, and names a directory, cd to it.
    setopt   AUTO_PUSHD # Make `cd` behave like `pushd`.
    setopt   CDABLE_VARS # `cd param` => `cd ~param` => `cd /path/to/dir`
    setopt   PUSHD_IGNORE_DUPS # Don't push multiple copies of the same dir onto the stack.
    setopt   PUSHD_TO_HOME # `pushd` with no args == `pushd $HOME`.

  #--------------
  #  Completion
  #--------------

    setopt   AUTO_LIST # Automatically list choices on an ambiguous completion.
    setopt   AUTO_MENU # Use a menu after the second <tab> for an ambiguous completion.
    setopt   AUTO_NAME_DIRS # param=/path/to/dir => ~param.
    setopt   AUTO_PARAM_KEYS # Automatically complete characters that have to come after a parameter name.
    setopt   AUTO_PARAM_SLASH # Automatically add trailing slashes to parameters containing directory names.
    unsetopt AUTO_REMOVE_SLASH # Don't remove slashes at the end of completed dirnames.
    setopt   GLOB_COMPLETE # Allow cycling through expansions using globs.
    setopt   HASH_LIST_ALL # The first time completion is attempted, hash the whole PATH.
    setopt   LIST_TYPES # Show the type of file in completions with a trailing character.
    setopt   REC_EXACT # During completion, recognize exact matches even if they are ambiguous.

  #--------------------------
  #  Expansion and Globbing
  #--------------------------

    setopt   BAD_PATTERN # Raise errors for badly-formed filename generation patterns.
    setopt   EXTENDED_GLOB # More powerful globbing with `#`, `~` and `^`.
    setopt   GLOB # Enable globbing.
    setopt   CSH_NULL_GLOB # Only raise an error if all arguments to a command are null globs.
    setopt   NUMERIC_GLOB_SORT # Sort numeric filenames numerically when using globs.
    setopt   RC_EXPAND_PARAM # $xx = (a b c); foo${xx}bar => (fooabar foobbar foocbar)

  #-----------
  #  History
  #-----------

    setopt   BANG_HIST # Enable textual history substitution, using !-syntax.
    setopt   EXTENDED_HISTORY # Save beginning and ending timestamps to the history file.
    setopt   HIST_ALLOW_CLOBBER # Allow clobbering (with pipes) in the command history.
    setopt   HIST_IGNORE_SPACE # Don't remember space-prefixed commands.
    setopt   HIST_REDUCE_BLANKS # Remove superfluous blanks from commands being added to the history.
    setopt   APPEND_HISTORY # Parallel zsh sessions will append their history to the history file.

  #----------------
  #  Input/Output
  #----------------

    unsetopt CORRECT # Attempt to correct the spelling of commands.
    unsetopt CORRECT_ALL # Attempt to correct all arguments in a line.
    setopt   INTERACTIVE_COMMENTS # Allow comments in the interactive shell.
    unsetopt HASH_CMDS # Use command hashing the first time a command is called.
    setopt   MAIL_WARNING # Inform me if I have system mail.
    setopt   RC_QUOTES # 'Zack''s Shell' => "Zack's Shell"

  #---------------
  #  Job Control
  #---------------

    setopt   AUTO_CONTINUE # Send stopped jobs a CONTINUE signal after they're disowned.
    setopt   AUTO_RESUME # Single-word simple commands will resume a currently-running job.
    unsetopt BG_NICE # Don't set background tasks to a lower priority.
    setopt   LONG_LIST_JOBS # List jobs in the long format by default.
    setopt   NOTIFY # Report the status of background jobs immediately, rather than waiting until the next prompt.

  #-------------
  #  Prompting
  #-------------

    setopt   PROMPT_SUBST # Perform substitution/expansion in prompts.

  #-------------------------
  #  Scripts and Functions
  #-------------------------

    setopt   FUNCTION_ARGZERO # Set $0 to the name of a function/script when running.
    setopt   MULTIOS # Perform implicit `tee`s or `cat`s for multiple redirections.

#===============
#  ZSH MODULES
#===============

  zmodload zsh/stat
  zmodload -a mapfile
  zmodload zsh/terminfo

  autoload colors; colors # ANSI color codes
  zmodload zsh/complist
  autoload -U compinit; compinit # Completion

#===================
#  VIEWING/EDITING
#===================

  export PAGER='less'
  alias more='less'

#==========
#  HELPERS
#==========
n_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

n_find_up() {
  local path_
  path_="${PWD}"
  while [ "${path_}" != "" ] && [ ! -f "${path_}/${1-}" ]; do
    path_=${path_%/*}
  done
  n_echo "${path_}"
}

n_find_nvmrc() {
  local dir
  dir="$(n_find_up '.nvmrc')"
  if [ -e "${dir}/.nvmrc" ]; then
    n_echo "${dir}/.nvmrc"
  fi
}

#==========
#  PROMPT
#==========
  _ruby_version() {
    if {echo $fpath | grep -q "plugins/rvm"}; then
      echo "%{$fg[grey]%}$(rvm_prompt_info)%{$reset_color%}"
    elif {echo $fpath | grep -q "plugins/rbenv"}; then
      echo "%{$fg[grey]%}$(rbenv_prompt_info)%{$reset_color%}"
    fi
  }

  _user_host() {
    if [[ -n $SSH_CONNECTION ]]; then
      me="%n@%m"
    elif [[ $LOGNAME != $USER ]]; then
      me="%n"
    else
      me="$(whoami)"
    fi
    if [[ -n $me ]]; then
      echo "%{$fg[yellow]%}$me%{$reset_color%}: "
    fi
  }

  _virtualenv_prompt () {
    if [[ -n $VIRTUAL_ENV ]]; then
      echo "$reset_color workon$fg[cyan]" `basename "$VIRTUAL_ENV"`
    fi
  }

  _node_version() {
    local node_version="$(node --version)"
    local nvmrc_path="$(n_find_nvmrc)"
    
    if [ -n "$nvmrc_path" ]; then
      local nvm_version="$(cat "${nvmrc_path}")"
      if [ "$node_version" != "$nvm_version" ]; then
        local v=$nvm_version
      fi
    fi
    [ "$v" != "" ] && echo "[%{$fg[cyan]%}⚠️  node:${v:1}%{$reset_color%}] "
  }

  local _current_dir="%{$fg_bold[green]%}%3~%{$reset_color%} "
  _current_dir() {
    local _max_pwd_length="65"
    if [[ $(echo -n $PWD | wc -c) -gt ${_max_pwd_length} ]]; then
      echo "%{$fg_bold[green]%}%-2~ ... %3~%{$reset_color%} "
    else
      echo "%{$fg_bold[green]%}%~%{$reset_color%} "
    fi
  }

  _git_prompt () {
    test -z "$(pwd | egrep '/\.git(/|$)')" || return
    local _git_branch="`git branch 2>/dev/null | egrep '^\*' | sed 's/^\* //'`"
    test -z "$_git_branch" && return
    local _git_status=`git status --porcelain | sort | awk '
      BEGIN { modified = 0; staged = 0; new = 0; }
      /^ / { modified += 1 }
      /^[^\? ]/ { staged += 1 }
      /^\?/ { new += 1 }
      END {
        if (staged) { print "∆"; exit }
        if (modified) { print "∂"; exit }
        if (new) { print "≈"; exit }
      }'`
    if [[ -n $_git_status ]]; then
      _git_status=":%{$fg[yellow]%}$_git_status%{$reset_color%}]"
    else
      _git_status="]  "
    fi
    echo -n "[%{$fg[gray]%}±%{$reset_color%}:%{$fg[blue]%}$_git_branch%{$reset_color%}$_git_status"
  }

  PROMPT='
$(_user_host)$(_current_dir)$(_virtualenv_prompt)
%{$fg[magenta]%}❯❯%{$reset_color%} '

  if which git >/dev/null 2>&1; then
    # RPROMPT='$(git_prompt.rb)'
    RPROMPT='$(_ruby_version) $(_node_version)$(_git_prompt)'
  fi

#================
#  KEY BINDINGS
#================

  # Ctrl-A, Ctrl-E
  bindkey '^a' beginning-of-line
  bindkey '^e' end-of-line

  # Arrow Keys
  # bindkey "$terminfo[kcuu1]" up-line-or-history
  # bindkey "$terminfo[kcud1]" down-line-or-history
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down
  bindkey '[C' forward-word
  bindkey '[D' backward-word

  # Misc
  ## bindkey ' ' magic-space # Do history expansion on space
  bindkey '^r' history-incremental-search-backward
  bindkey "^[[3~" delete-char
  bindkey "^?" backward-delete-char

#========
#  RUBY
#========

  [[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm

#=============
#  FUNCTIONS
#=============

  abspath () {
    # abspath <directory>
    # Print the absolute path to a given file (using Python's `os.path.abspath()`).
    python -c 'import os, sys; print os.path.abspath(sys.argv[1])' "$@"
  }

#===========
#  ALIASES
#===========

  if [ $PLATFORM = Linux ]; then
    alias ls='ls -F --color=auto'
  else
    alias ls='ls -FG'
  fi
  alias dir='ll'
  alias l='ll'
  alias ll='ls -lh'
  alias la='ls -A'
  alias curl='curl -s'
  alias tree='tree -C --dirsfirst'
  alias rmpyc='find . -name "*.pyc" -delete'
  alias mailenc='gpg2 --armor --sign --encrypt'
  alias moar='curl -s "http://meme.boxofjunk.ws/moar.txt?lines=1"'
  alias wtcommit='curl -s "http://whatthecommit.com/index.txt"'
  alias top='top -ocpu'
  alias dj='django-admin.py'

  if [ -f ~/.wcookies ]; then
    alias download="wget -c --load-cookies ~/.wcookies"
  fi

#=====================
#  COMPLETION STYLES
#=====================

  zstyle ':completion::complete:*' use-cache on
  zstyle ':completion::complete:*' cache-path ~/.zsh/cache/$HOST

  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
  zstyle ':completion:*' menu select=1 _complete _ignored _approximate
  zstyle -e ':completion:*:approximate:*' max-errors \
      'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'
  zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
  zstyle ':completion:*:processes' command 'ps -axw'
  zstyle ':completion:*:processes-names' command 'ps -awxho command'
  # Completion Styles
  zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
  # list of completers to use
  zstyle ':completion:*::::' completer _expand _complete _ignored _approximate

  # allow one error for every three characters typed in approximate completer
  zstyle -e ':completion:*:approximate:*' max-errors \
      'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

  # insert all expansions for expand completer
  zstyle ':completion:*:expand:*' tag-order all-expansions

  # NEW completion:
  #  1. All /etc/hosts hostnames are in autocomplete
  #  2. If you have a comment in /etc/hosts like #%foobar.domain,
  #     then foobar.domain will show up in autocomplete!
  zstyle ':completion:*' hosts $(awk '/^[^#]/ {print $2 $3" "$4" "$5}' /etc/hosts | grep -v ip6- && grep "^#%" /etc/hosts | awk -F% '{print $2}')
  # formatting and messages
  zstyle ':completion:*' verbose yes
  zstyle ':completion:*:descriptions' format '%B%d%b'
  zstyle ':completion:*:messages' format '%d'
  zstyle ':completion:*:warnings' format 'No matches for: %d'
  zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
  zstyle ':completion:*' group-name ''

  # match uppercase from lowercase
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

  # offer indexes before parameters in subscripts
  zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

  # command for process lists, the local web server details and host completion
  zstyle ':completion:*:processes' command 'ps -o pid,s,nice,stime,args'
  # zstyle ':completion:*:urls' local 'www' '/var/www/htdocs' 'public_html'
  zstyle '*' hosts $hosts

  # Filename suffixes to ignore during completion (except after rm command)
  zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~' \
      '*?.old' '*?.pro'
  # the same for old style completion
  #fignore=(.o .c~ .old .pro)

  # ignore completion functions (until the _ignored completer)
  zstyle ':completion:*:functions' ignored-patterns '_*'
  zstyle ':completion:*:scp:*' tag-order \
     files users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
  zstyle ':completion:*:scp:*' group-order \
     files all-files users hosts-domain hosts-host hosts-ipaddr
  zstyle ':completion:*:ssh:*' tag-order \
     users 'hosts:-host hosts:-domain:domain hosts:-ipaddr"IP\ Address *'
  zstyle ':completion:*:ssh:*' group-order \
     hosts-domain hosts-host users hosts-ipaddr
  zstyle '*' single-ignored show

#===========
#  FINALLY
#===========

if [ -f ~/.zsh_profile ]; then
  . ~/.zsh_profile
fi
