################################################
#
#	For your local overrides there are several configs in ${HOME}/.config/bash/
#	* aliases.local
#	* functions.local
#	* rc.local
#
################################################

# If not running interactively, don't do anything
if command -v zsh >/dev/null 2>&1; then
	zsh -l
fi
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

[[ -f ${HOME}/.proxy.local ]] && source ${HOME}/.proxy.local

DOT_PATH=${HOME}/.homesick/repos/dotfiles
RC_PATH=${DOT_PATH}/shell_bash

# Load homeshick
if [ ! -d ${HOME}/.homesick ]; then
	git clone https://github.com/andsens/homeshick.git ${HOME}/.homesick/repos/homeshick
	source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
	source "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash"
	homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
	homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
	homeshick --quiet --batch --force link
	fc-cache -fv
fi

# Additional settings
source "${RC_PATH}/rc"

source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
source "${HOME}/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet --batch --force pull
homeshick --quiet --batch --force link

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
