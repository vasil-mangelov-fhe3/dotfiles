#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_sync_dotfiles() {
  if _nredf_last_run; then
    return 0
  fi

  echo -e '\033[1mChecking dotfiles\033[0m'
  if [ ! -d "${HOME}/.homesick" ]; then
    echo -e '\033[1m  Cloning homesick\033[0m'
    git clone https://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
    source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
    fpath=("${HOME}/.homesick/repos/homeshick/completions ${fpath[@]}")
    echo -e '\033[1m  Cloning dotfiles\033[0m'
    homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
    echo -e '\033[1m  Cloning vimfiles\033[0m'
    homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
    echo -e '\033[1m  Cloning asdf\033[0m'
    homeshick --quiet --batch clone https://github.com/asdf-vm/asdf.git
    source "${HOME}/.homesick/repos/asdf/completions/asdf.bash"
    fpath=("${HOME}/.homesick/repos/asdf/completions ${fpath[@]}")
    echo -e '\033[1m  Linking dotfiles\033[0m'
    homeshick --quiet --batch --force link
    fc-cache -fv
    _nredf_last_run "" "true"
    exec ${SHELL}
  else
    source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
    fpath=("${HOME}/.homesick/repos/homeshick/completions" "${fpath[@]}")
    homeshick --quiet check
    case ${?} in
      86)
        echo -e '\033[1m  Pulling dotfiles\033[0m'
        homeshick --batch --force pull
        echo -e '\033[1m  Linking dotfiles\033[0m'
        homeshick --batch --force link
        exec ${SHELL}
        ;;
      85)
        echo -e '\033[1;38;5;222m  Your dotfiles are ahead of its upstream, consider pushing\033[0m'
        echo -e '\033[1m  Linking dotfiles\033[0m'
        homeshick --batch --force link
        ;;
      88)
        echo -e '\033[1;38;5;222m  Your dotfiles are modified, commit or discard changes to update them\033[0m'
        echo -e '\033[1m  Linking dotfiles\033[0m'
        homeshick --batch --force link
        ;;
    esac
    _nredf_last_run "" "true"
  fi
}
