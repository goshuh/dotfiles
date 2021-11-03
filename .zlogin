#!/usr/bin/zsh

if [[ -z ${GOSH_INITED} && ${XDG_VTNR} -ge 2 && ${XDG_VTNR} -le 3 ]]; then
    export GOSH_INITED=1

    # special usage
    rc=${HOME}/.init.d/rc.$((XDG_VTNR - 1))

    if [[ -x ${rc} ]]; then
        exec ${rc}
    fi
fi
