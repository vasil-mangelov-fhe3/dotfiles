################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/zsh/
#	* aliases.local
#	* functions.local
#	* rc.local
#	* plugins.local
#
################################################

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

[[ -f ${HOME}/.proxy.local ]] && source ${HOME}/.proxy.local

DOT_PATH=${HOME}/.homesick/repos/dotfiles
RC_PATH=${DOT_PATH}/shell_zsh

# Load homeshick
if [ ! -d ${HOME}/.homesick ]; then
	git clone git://github.com/andsens/homeshick.git ${HOME}/.homesick/repos/homeshick
	source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
	fpath=(${HOME}/.homesick/repos/homeshick/completions ${fpath})
	homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
	homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
	homeshick --quiet --batch --force link
	fc-cache -fv
else
	source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
	fpath=(${HOME}/.homesick/repos/homeshick/completions ${fpath})
	homeshick --quiet --batch --force pull
	homeshick --quiet --batch --force link
fi

# Set a different zplug path
ZPLUG_HOME=${RC_PATH}/zplug
ZPLUG_PLUGINS=${RC_PATH}/plugins
ZPLUG_LOADFILE=${RC_PATH}/plugins.local
[[ ! -f ${ZPLUG_LOADFILE} ]] && touch ${ZPLUG_LOADFILE}
PLUGINSRC=${RC_PATH}/pluginsrc

if [[ -d ${ZPLUG_HOME} ]]; then
	source ${ZPLUG_HOME}/init.zsh
	source ${ZPLUG_PLUGINS}
	source ${ZPLUG_LOADFILE}

	if ! zplug check; then
		zplug install
	fi

	# source plugins and add commands to the PATH
	zplug load
else
	git clone https://github.com/zplug/zplug ${ZPLUG_HOME}
	source ${ZPLUG_HOME}/init.zsh
	source ${ZPLUG_PLUGINS}
	source ${ZPLUG_LOADFILE}
	zplug install
	zplug load
fi

# Additional settings
source ${RC_PATH}/rc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
