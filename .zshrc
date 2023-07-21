# env vars
export SAVEHIST=65536
export HISTSIZE=65536
export HISTFILE=~/.zhistory


# aliases
if [[ -z ${commands[nvim]} ]]; then
    alias  v="vim"
    alias  g="gvim"
    alias vv="sudo vim"

    if [[ -z ${commands[gvim]} || ${EUID} -eq 0 ]]; then
        alias g="vim"
    fi
else
    alias  v="nvim"
    alias  g="nvim-qt"
    alias vv="sudo nvim"

    if [[ -z ${commands[nvim-qt]} || ${EUID} -eq 0 ]]; then
        alias g="nvim"
    fi
fi

alias     a="cd /tmp/ram"
alias     ,="cd .."
alias    ,,="cd ../.."
alias     /="cd -"
alias    vf="vifm"
alias    vj='cd "$(vifm --choose-dir=-)"'

if [[ -z ${commands[exa]} ]]; then
    alias  l="ls -A --indicator-style=none --color=auto"
    alias ll="ls -A --indicator-style=none --color=auto -aghot"
else
    alias  l="exa"
    alias ll="exa -alr --time=accessed --sort=accessed"
fi

alias  grep="grep --color=auto"

alias     r="rm -rf"
alias     k="kill -9"

alias     t="tmux"
alias    ta="tmux attach"

alias    ps="ps x"
alias    pg="ps | grep"
alias  mren="md5sum * | sed -e 's/\([^ ]*\) \(.*\(\..*\)\)$/mv -v \2 \1\3/e'"

alias    gs="git status"
alias    gd="git diff"
alias    gl="git log"
alias    gp="git log -p"
alias    gb="git blame"
alias    gm="git submodule"

alias   gga="git add"
alias   ggb="git branch"
alias   ggc="git checkout --recurse-submodules"
alias   ggm="git commit -m"
alias   ggp="git pull && git submodule update --recursive"
alias   ggg="git push"

alias    ss="systemctl --user start"
alias    st="systemctl --user stop"
alias    sr="systemctl --user restart"

alias    mm="machinectl"
alias    ms="machinectl start"
alias    ml="machinectl login"
alias    mx="machinectl shell"

if [[ -n ${commands[pacman]}  ]]; then
    alias  pac="sudo pacman"
    alias pacs="sudo pacman -S"
    alias pacr="sudo pacman -Rsn"
    alias pacf="pacman -Ss"
    alias paco="pacman -Qo"
fi
if [[ -n ${commands[yum]}     ]]; then
    alias  pac="sudo yum"
    alias pacs="sudo yum install"
    alias pacr="sudo yum remove"
    alias pacf="yum search"
    alias paco="yum whatprovides"
fi
if [[ -n ${commands[apt-get]} ]]; then
    alias  pac="sudo apt"
    alias pacs="sudo apt install"
    alias pacr="sudo apt autoremove --purge"
    alias pacf="apt search"
    alias paco="dpkg -S"
fi

if [[ -f ${HOME}/.alias ]]; then
    source ${HOME}/.alias
fi


# configs
setopt APPEND_HISTORY
setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_KEYS
setopt AUTO_PARAM_SLASH
setopt AUTO_PUSHD
setopt BRACE_CCL
setopt CDABLE_VARS
setopt COMPLETE_IN_WORD
setopt CORRECT
setopt GLOB_DOTS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt IGNORE_EOF
setopt INTERACTIVE_COMMENTS
setopt KSH_TYPESET
setopt LIST_TYPES
setopt MENU_COMPLETE
setopt MULTIOS
setopt NO_BEEP
setopt NO_LIST_BEEP
setopt NO_HIST_BEEP
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt PUSHD_TO_HOME

limit coredumpsize 0


PROMPT="%{[1m%}%{[38;2;229;192;123m%}%D{%H:%M}%{[38;2;152;195;121m%} %~ %(!.%{[38;2;232;102;113m%}.%{[38;2;97;175;239m%})>>>%{[0m%} "


# keybindings
bindkey -v
bindkey -s "" "cd -\t"

bindkey "[A"  history-beginning-search-backward
bindkey "[B"  history-beginning-search-forward
bindkey "[C"  forward-char
bindkey "[6~" forward-word
bindkey "[D"  backward-char
bindkey "[5~" backward-word
bindkey "[3~" delete-char

bindkey "[1~" beginning-of-line
bindkey "[7~" beginning-of-line
bindkey "[H"  beginning-of-line
bindkey "[4~" end-of-line
bindkey "[8~" end-of-line
bindkey "[F"  end-of-line

# nvim hack (#6134)
bindkey "OA"  history-beginning-search-backward
bindkey "OB"  history-beginning-search-forward
bindkey "OH"  beginning-of-line
bindkey "OF"  end-of-line

spawn_term () {
    ${TERMINAL:-gnome-terminal} &!
}
clean_jobs () {
    builtin kill %1
}

zle -N spawn_term
zle -N clean_jobs

# insert
bindkey "[2~" spawn_term
bindkey "^_"      clean_jobs


# completions
autoload -Uz compinit

compinit

zstyle ":completion:*" completer _complete _prefix _correct _prefix _match _approximate
zstyle ":completion:*" expand "yes"
zstyle ":completion:*" group-name ""
zstyle ":completion:*" matcher-list "" "m:{a-zA-Z}={A-Za-z}"
zstyle ":completion:*" menu select
zstyle ":completion:*" squeeze-slashes "yes"
zstyle ":completion:*" verbose yes
zstyle ":completion:*:approximate:*" max-errors 1 numeric
zstyle ":completion:*:matches" group "yes"
zstyle ":completion:*:match:*" original only
zstyle ":completion:*:options" auto-description "%d"
zstyle ":completion:*:options" description "yes"
zstyle ":completion:*:processes" command "ps -au$USER"
zstyle ":completion:*:*:default" force-list always
zstyle ":completion:*:*:kill:*" menu yes select
zstyle ":completion:*:*:*:default" menu yes select
zstyle ":completion:*:*:*:*:processes" force-list always
zstyle ":completion::complete:*" "\\"
zstyle ":completion::prefix-1:*" completer _complete
zstyle ":completion:incremental:*" completer _complete _correct
zstyle ":completion:predict:*" completer _complete
zstyle ":completion:*:corrections" format $"[38;5;147m >>> [38;5;68m%d (%e)[0m"
zstyle ":completion:*:descriptions" format $"[38;5;147m >>> [38;5;68m%d[0m"
zstyle ":completion:*:messages" format $"[38;5;147m >>> [38;5;68m%d[0m"
zstyle ":completion:*:warnings" format $"[38;5;147m >>> [38;5;68mnot found[0m"
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=38;5;147"


# functions
chpwd() {
    if [[ -z ${commands[exa]} ]]; then
        ls -A --indicator-style=none --color=auto
    else
        exa
    fi
}

preexec() {
    print -Pn "\e]0;$2:q\a"
}
