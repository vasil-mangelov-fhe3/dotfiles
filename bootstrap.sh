#!/bin/bash

# Paste this into ssh
# curl -sL https://repo.nrecom.net/nre-com-net/dotfiles/raw/master/bootstrap.sh | /bin/bash
# When forking, you can get the URL from the raw (<>) button.

### Set some command variables depending on whether we are root or not ###
# This assumes you use a debian derivate, replace with yum, pacman etc.
aptget='sudo apt-get'
if [ `whoami` = 'root' ]; then
    aptget='apt-get'
fi

### Install git and some other tools we'd like to use ###
$aptget update
$aptget install -y tmux vim git screen htop

### Install homeshick ###
git clone git://github.com/andsens/homeshick.git $HOME/.homesick/repos/homeshick
source $HOME/.homesick/repos/homeshick/homeshick.sh

homeshick --batch clone https://repo.nrecom.net/nre-com-net/dotfiles.git
homeshick --batch clone https://repo.nrecom.net/nre-com-net/vimfiles.git

### Link it all to $HOME ###
homeshick link --force

echo "Log in again to start your proper shell"
