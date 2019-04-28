#!/usr/bin/zsh

export LESS_TERMCAP_md='[38;5;147m'
export LESS_TERMCAP_mb='[38;5;182m'
export LESS_TERMCAP_me='[0m'
export LESS_TERMCAP_so='[38;5;187m'
export LESS_TERMCAP_se='[0m'
export LESS_TERMCAP_us='[38;5;68m'
export LESS_TERMCAP_ue='[0m'

# per vt
rc=${HOME}/.init.d/rc.${DISPLAY:1}

if [[ -x ${rc} ]]; then
    exec ${rc}
fi
