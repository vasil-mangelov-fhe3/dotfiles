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
export RC_PATH=${DOT_PATH}/shell/zsh
export RC_LOCAL=${HOME}/.config/zsh

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

source ${DOT_PATH}/shell/common/prerc
source ${RC_PATH}/zplugrc
source ${RC_PATH}/rc
source ${DOT_PATH}/shell/common/commonrc
source ${DOT_PATH}/shell/common/postrc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh && source ${RC_PATH}/fzf

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
