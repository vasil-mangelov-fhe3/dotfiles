################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/bash/
#	* aliases.local
#	* functions.local
#	* rc.local
#
################################################

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

[[ -f ${HOME}/.proxy.local ]] && source ${HOME}/.proxy.local

DOT_PATH=${HOME}/.homesick/repos/dotfiles
RC_PATH=${DOT_PATH}/shell_bash

# Load homeshick
if [ ! -d ${HOME}/.homesick ]; then
	git clone git://github.com/andsens/homeshick.git ${HOME}/.homesick/repos/homeshick
	source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
	source "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash"
	homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
	homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
	homeshick --quiet --batch --force link
	fc-cache -fv
else
	source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
	source "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash"
	homeshick pull -q
	homeshick link -q
fi

# Additional settings
source "${RC_PATH}/rc"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
