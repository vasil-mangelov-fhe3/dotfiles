################################################
#
#
#	For Entries that you want only local or
#	per user use ${HOME}/.config/bash/localrc
#
#
################################################

# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

export PATH=${HOME}/bin:/usr/local/bin:${PATH}

RC_PATH=${HOME}/.config/bash

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

source "${RC_PATH}/rc"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
