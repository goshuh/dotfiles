#!/usr/bin/zsh

if [[ -z ${DISPLAY} && ${XDG_VTNR} -le 3 ]]; then

    # special usage
    rc=${HOME}/.init.d/rc.$((XDG_VTNR - 1))

    if [[ -x ${rc} ]]; then
        exec ${rc}
    fi
fi
