################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/bash/
#	* aliases.local
#	* functions.local
#	* rc.local
#
################################################

export DOT_PATH=${HOME}/.homesick/repos/dotfiles
export RC_PATH=${DOT_PATH}/shell_bash
export PATH=${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}
export GOPATH=${HOME}/.local

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

source ${DOT_PATH}/shell_common/prerc
source ${RC_PATH}/rc
source ${DOT_PATH}/shell_common/commonrc
source ${DOT_PATH}/shell_common/postrc

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
