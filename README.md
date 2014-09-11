# NRE.Com.Net Dotfiles

## Description
This is our compilation of dotfiles, they are build to be managed by [Anders Ingemann's homeshick](https://github.com/andsens/homeshick)


**NOTE:**
This includes 
* [revans bash-it](https://github.com/revans/bash-it/wiki/Themes#powerline) Powerline Theme 
* [Lokaltogs powerline-fonts](https://github.com/Lokaltog/powerline-fonts) which is installed into "${HOME}/.fonts"
* [seebis solarized dircolors ](https://github.com/seebi/dircolors-solarized#theme-1-256dark-by-seebi) which is installed into "${HOME}/.config"
* [seebis solarized tmux theme](https://github.com/seebi/tmux-colors-solarized)
* [tmux-plugins tpm](https://github.com/tmux-plugins/tpm) disabled at the moment
* a huge compilation of vim Plugins ([Pluginlist](https://github.com/NemesisRE/dotfiles/blob/master/home/.vim/rc/neobundle.rc.vim))

All contribution goes to the original developers we only have put the pieces together.

## Install

### Manual
1. Install homeshick like in the [Readme](https://github.com/andsens/homeshick/blob/master/README.md)
2. Add NRE.Com.Net Dotfiles to homeshick `homeshick clone https://github.com/NemesisRE/dotfiles.git`
3. Add our bashrc to your existing `printf '\nsource "${HOME}/.bashrc_homesick"' >> ${HOME}/.bashrc`

**NOTE:**
We sugest to install [Lokaltog powerline-fonts](https://github.com/Lokaltog/powerline-fonts) to "$HOME/.fonts"
and run `fc-cache -fv` (The bootstrap script includes and installes/registers them automatically.).
Then you should restart your terminal application and change the font to a powerline one.


### Bootstraped
1. `curl -sL https://raw.githubusercontent.com/NemesisRE/dotfiles/master/bootstrap.sh | /bin/bash`
