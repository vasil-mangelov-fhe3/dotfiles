################################################
#
#
#	For Entries that you want only local or
#	per user use ${HOME}/.config/zsh/localrc
#
#
################################################

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

RC_PATH=${HOME}/.config/zsh

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=${RC_PATH}

# Additional settings
source ${RC_PATH}/rc

# Set a different zgen path
ZGEN_DIR=${HOME}/.config/zgen

# load zgen
source "${ZGEN_DIR}/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
	# specify plugins in this file
	source ${RC_PATH}/zgen_plugins
	# generate the init script from plugins above
	zgen save
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
