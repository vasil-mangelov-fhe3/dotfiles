################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/bash/
#	* aliases.local
#	* functions.local
#	* rc.local
#
################################################

export DOT_PATH="${HOME}/.homesick/repos/dotfiles"
export RC_PATH="${DOT_PATH}/shell/bash"
export RC_LOCAL="${HOME}/.config/bash"

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

source "${DOT_PATH}/shell/common/prerc"
source "${RC_PATH}/rc"
source "${DOT_PATH}/shell/common/commonrc"
source "${DOT_PATH}/shell/common/postrc"
