################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/zsh/
#	* aliases.local
#	* functions.local
#	* rc.local
#	* plugins.local
#
################################################

export DOT_PATH=${HOME}/.homesick/repos/dotfiles
export RC_PATH=${DOT_PATH}/shell_zsh
export RC_LOCAL=${HOME}/.config/zsh

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

source ${DOT_PATH}/shell_common/prerc
source ${RC_PATH}/zplugrc
source ${RC_PATH}/rc
source ${DOT_PATH}/shell_common/commonrc
source ${DOT_PATH}/shell_common/postrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
