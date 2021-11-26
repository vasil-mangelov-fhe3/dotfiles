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

export DOT_PATH="${HOME}/.homesick/repos/dotfiles"
source "${DOT_PATH}/shell/common/rc"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
