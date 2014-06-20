#!/bin/bash

# Paste this into ssh
# curl -sL https://raw.githubusercontent.com/NemesisRE/dinner/master/bootstrap.sh | /bin/bash
# When forking, you can get the URL from the raw (<>) button.

### Set some command variables depending on whether we are root or not ###
# This assumes you use a debian derivate, replace with yum, pacman etc.
if [ $(whoami) = 'root' ]; then
	APT='apt-get'
else
	APT='sudo apt-get'
fi

### Install git and some other tools we'd like to use ###
${APT} update
${APT} install -y tmux vim git screen htop

### Install homeshick ###
git clone git://github.com/andsens/homeshick.git ${HOME}/.homesick/repos/homeshick
source ${HOME}/.homesick/repos/homeshick/homeshick.sh

homeshick --batch clone https://github.com/NemesisRE/dotfiles.git

### Link it all to $HOME ###
homeshick link

### Install bash-it with NRE.Com.Net defaults ###
${HOME}/.homesick/repos/dotfiles/bash-it/install.sh defaults

# Register powerline fonts
fc-cache -fv

# Source .bashrc_homesick in .bashrc
grep -xq 'source "${HOME}/.bashrc_homesick"' ${HOME}/.bashrc || printf '\nsource "${HOME}/.bashrc_homesick"' >> ${HOME}/.bashrc

echo "Relog to start your proper shell"
