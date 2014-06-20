# NRE.Com.Net Dotfiles

This is our compilation of dotfiles, they are build to be managed by [Anders Ingemann's homeshick](https://github.com/andsens/homeshick)
All contribution goes to the original developers we only have put the pieces together.

This includes [Lokaltog powerline-fonts](https://github.com/Lokaltog/powerline-fonts) which are installed to "${HOME}/.fonts"

## Install

### Manual
1. Install homeshick like in the [Readme](https://github.com/andsens/homeshick/blob/master/README.md)
2. Add NRE.Com.Net Dotfiles to homeshick `homeshick clone https://github.com/NemesisRE/dotfiles.git`
3. Add our bashrc to your existing `printf '\nsource "${HOME}/.bashrc_homesick"' >> ${HOME}/.bashrc`

### Bootstraped
**NOTE:**
This will also install [revans bash-it](https://github.com/revans/bash-it) with some [NRE.Com.Net defaults](https://github.com/NemesisRE/dotfiles/tree/master/bash-it)

1. `curl -sL https://raw.githubusercontent.com/NemesisRE/dinner/master/bootstrap.sh | /bin/bash`


**NOTE:**
We sugest to install [Lokaltog powerline-fonts](https://github.com/Lokaltog/powerline-fonts) to "$HOME/.fonts"
and run `fc-cache -fv` (The bootstrap script includes and installes/registers them automatically.).
Then you should restart your terminal application and change the font to a powerline one.
