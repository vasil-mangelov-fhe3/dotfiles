#!/bin/bash
# Paste this into ssh
# curl -sL https://raw.githubusercontent.com/NemesisRE/dotfiles/master/bootstrap.sh | /bin/bash
# When forking, you can get the URL from the raw (<>) button.

echo "needs to be fixed"
exit 0
SCRIPT_NAME=$(basename ${0})
SCRIPT_PATH=$(cd $(dirname ${0}) && pwd)
TMP_PATH=/tmp/nrecomnet
LOG_DIR=${TMP_PATH}
rm -rf ${TMP_PATH}
if ! [[ -e ${TMP_PATH}/log.sh ]]; then
	[[ -d ${TMP_PATH} ]] || mkdir ${TMP_PATH}
	$(which wget) --quiet https://raw.githubusercontent.com/NemesisRE/dotfiles/master/helper/log.sh -O ${TMP_PATH}/log.sh
fi
source ${TMP_PATH}/log.sh

### Set some command variabl:qes depending on whether we are root or not ###
# This assumes you use a debian derivate, replace with yum, pacman etc.
if [ $(whoami) = 'root' ]; then
	APT='apt-get'
else
	APT='sudo apt-get'
fi

function _install_dotfiles() {
	local ANSWER
	until [[ -n ${ANSWER} ]]; do
		_e_pending "Do you want to install NRE.Com.Net Dotfiles? (y/N): "  "ACTION" "${BLYLW}" "0"
		read -n1 ANSWER
	done
	if [[ "${ANSWER}" =~ [yY] ]]; then
		DOTFILES=true
		_exec_command "_run_dotfiles_installation"
		_e_pending_success "Successfully installed NRE.Com.Net Dotfiles."
		_e_notice "Relog to start your proper shell"
	else
		DOTFILES=false
		_e_pending_skipped "Installation of NRE.Com.Net Dotfiles skipped."
	fi
}

function _run_dotfiles_installation() {
	if [[ -d ${HOME}/.homesick/repos/dotfiles ]]; then
		rm -rf ${HOME}/.homesick/repos/dotfiles
	fi
	homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
	homeshick --quiet --batch --force link
	# Register fonts
	fc-cache -fv
	# Source .bashrc_homesick in .bashrc
	grep -xq 'source "${HOME}/.bashrc_homesick"' ${HOME}/.bashrc || printf '\nsource "${HOME}/.bashrc_homesick"' >> ${HOME}/.bashrc
}

function _install_vimfiles() {
	local ANSWER
	until [[ -n ${ANSWER} ]]; do
		_e_pending "Do you want to install NRE.Com.Net Vim Environment? (y/N): "  "ACTION" "${BLYLW}" "0"
		read -n1 ANSWER
	done
	if [[ "${ANSWER}" =~ [yY] ]]; then
		if ${DOTFILES}; then
			_exec_command "_run_vimfiles_installation"
			vim +"set nomore" +qall
			_e_pending_success "Successfully installed NRE.Com.Net Vim Environment."
		else
			_e_pending_warn "The NRE.Com.Net Vim Environment needs Powerline Fonts to be correctly displayed."
			_e_notice "Look into the README how to manual install Powerline Fonts or install NRE.Com.Net Dotfiles."
			_exec_command "_run_vimfiles_installation"
			vim +"set nomore" +qall
			_e_pending_success "Successfully installed NRE.Com.Net Vim Environment."
		fi
	else
		_e_pending_skipped "Installation of NRE.Com.Net Vim Environment skipped."
	fi
}

function _run_vimfiles_installation () {
	if [[ -d ${HOME}/.homesick/repos/vimfiles ]]; then
		rm -rf ${HOME}/.homesick/repos/vimfiles
	fi
	homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
	homeshick --quiet --batch --force link
}

function _main() {
	### Install git and some other tools we'd like to use ###
	#${APT} update -qq
	#${APT} install -y tmux vim git screen htop exuberant-ctags

	### Install homeshick ###
	if [[ -d ${HOME}/.homesick/repos/homeshick ]]; then
		_e_notice "Homeshick seems already installed, moving on..."
	else
		git clone git://github.com/andsens/homeshick.git ${HOME}/.homesick/repos/homeshick
	fi
	source ${HOME}/.homesick/repos/homeshick/homeshick.sh
	_install_dotfiles
	_install_vimfiles
}

_main
