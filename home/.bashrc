################################################
#
#
#	For Entries that you want only local or
#	per user use ${HOME}/.config/bash/localrc
#
#
################################################

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

RC_PATH=${HOME}/.config/bash

source "${RC_PATH}/rc"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
