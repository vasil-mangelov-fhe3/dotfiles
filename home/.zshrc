################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/zsh/
#	* aliases.local
#	* functions.local
#	* rc.local
#	* plugins.local
#
################################################

DOT_PATH=${HOME}/.homesick/repos/dotfiles
RC_PATH=${DOT_PATH}/shell_zsh
source ${DOT_PATH}/shell_common/prerc
source ${RC_PATH}/zplugrc
source ${RC_PATH}/commonrc
source ${DOT_PATH}/shell_common/postrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
