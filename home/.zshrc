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

# Additional settings
source ${RC_PATH}/rc

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=${RC_PATH}

# Set a different zplug path
ZPLUG_HOME=${HOME}/.config/zplug
ZPLUG_LOADFILE=${RC_PATH}/plugins

if [[ -d ${ZPLUG_HOME} ]]; then
	source ${ZPLUG_HOME}/init.zsh
	source ${ZPLUG_LOADFILE}

	if ! zplug check; then
		zplug install
	fi

	# source plugins and add commands to the PATH
	zplug load
else
	git clone https://github.com/zplug/zplug ${ZPLUG_HOME}
	source ${ZPLUG_HOME}/init.zsh
	source ${ZPLUG_LOADFILE}
	zplug install
	zplug load
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
