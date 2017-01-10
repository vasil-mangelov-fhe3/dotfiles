################################################
#
#
#	For Entries that you want only local or
#	per user use ${HOME}/.config/bash/localrc
#
#
################################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

source "${HOME}/.config/bash/rc"
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
