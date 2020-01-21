# env vars
setenv TERM xterm-256color

# aliases
alias v    "vim"
alias g    "gvim"
alias vv   "sudo vim"

alias a    "cd /tmp/ram"
alias \,   "cd .."
alias \,\, "cd ../.."
alias /    "cd -"

alias l    "ls -A --indicator-style=none --color=auto"
alias ll   "ls -A --indicator-style=none --color=auto -aghot"
alias grep "grep --color=auto"

alias r    "rm -rf"
alias k    "kill -9"

alias t    "tmux"
alias ta   "tmux attach"

alias ps   "ps x"
alias pg   "ps x | grep"

alias gg   "grep --color=auto -rn '\!:1' . \!:2*"
alias ff   "find . -name '*\!{:1}*' \!:2*"

alias gs   "git status"
alias gd   "git diff"
alias gl   "git log"
alias gp   "git log -p"
alias gb   "git blame"

alias gga  "git add"
alias ggb  "git branch"
alias ggc  "git checkout"
alias ggm  "git commit -m"
alias ggp  "git pull"
alias ggg  "git push"

alias xt   "echo -n '\e]2;\!#:q\a'"

# configs
set history  = 65536
set histlit
set histdup  = erase
set prompt   = "%{\r\e[38;5;182m%}%d %T%{\e[38;5;147m%} %~ %{\e[38;5;68m%}>>>%{\e[0m%} "
set noding
set symlinks = ignore
set implicitcd
set autolist
set autoexpand
set autocorrect

# keybindings
bindkey -k up   history-search-backward
bindkey -k down history-search-forward

bindkey "^[[2~" backward-delete-word
bindkey "^[[5~" backward-word
bindkey "^[[6~" forward-word

if ( $?0 == 0 ) then
    # interactive only
    alias cwdcmd "ls -A --indicator-style=none --color=auto"
    # single shot
    alias precmd "alias postcmd 'xt; unalias postcmd'"
endif
