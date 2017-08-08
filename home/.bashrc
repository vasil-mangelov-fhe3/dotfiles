################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/bash/
#	* aliases.local
#	* functions.local
#	* rc.local
#
################################################

DOT_PATH=${HOME}/.homesick/repos/dotfiles
RC_PATH=${DOT_PATH}/shell_bash
source ${DOT_PATH}/shell_common/prerc
source ${RC_PATH}/rc
source ${DOT_PATH}/shell_common/commonrc
source ${DOT_PATH}/shell_common/postrc

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
