#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_set_ssh_agent() {
  if [[ -z ${SSH_CONNECTION} && "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    unset SSH_AGENT_PID
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
  fi
}

function _nredf_get_sys_info() {
  UNAMEM=$(uname -m)
  case ${UNAMEM} in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac

  UNAMES="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "${UNAMES}" in
    msys_nt*) PLATFORM="pc-windows-msvc" ;;
    cygwin_nt*) PLATFORM="pc-windows-msvc";;
    mingw*) PLATFORM="pc-windows-msvc" ;;
    linux) PLATFORM="unknown-linux-musl" ;;
    darwin) PLATFORM="apple-darwin" ;;
    freebsd) PLATFORM="unknown-freebsd" ;;
  esac

  OS=$(uname|tr '[:upper:]' '[:lower:]')
  case "${OS}" in
    mingw*) OS='windows';;
  esac

  SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  export ARCH OS PLATFORM SHELL_NAME
}

function _nredf_github_latest_release() {
  local GHUSER=${1}
  local GHREPO=${2}
  local CACHEFILE="${XDG_CACHE_HOME}/nredf/GHVersionCache/nredf_github_latest_release-${GHUSER}-${GHREPO}"

  if [[ ! -d "${XDG_CACHE_HOME}/nredf/GHVersionCache" ]]; then
    mkdir -p "${XDG_CACHE_HOME}/nredf/GHVersionCache"
  fi

  if [[ ! -f "${CACHEFILE}" || $(date -r "${CACHEFILE}" +%s) -le $(($(date +%s) - 3600 )) ]]; then
    curl -fs "https://api.github.com/repos/${GHUSER}/${GHREPO}/releases/latest" | grep -Po '"tag_name":"\K.*?(?=")' > "${CACHEFILE}"
  fi
  cat "${CACHEFILE}"
}

function _nredf_github_download_latest() {
  local GHUSER=${1}
  local GHREPO=${2}
  local GHFILE=${3}

  if [[ ! -d "${XDG_CACHE_HOME}/nredf/Download" ]]; then
    mkdir -p "${XDG_CACHE_HOME}/nredf/Download"
  fi

  curl -Lfso "${XDG_CACHE_HOME}/nredf/Download/${GHFILE}" "https://github.com/${GHUSER}/${GHREPO}/releases/latest/download/${GHFILE}"

  return ${?}
}

function _nredf_set_defaults() {
  [[ -f "${HOME}/.proxy.local" ]] && source "${HOME}/.proxy.local"
  # You may need to manually set your language environment
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

  export XDG_CONFIG_HOME="${HOME}/.config"
  export XDG_CACHE_HOME="${HOME}/.cache"
  export XDG_DATA_HOME="${HOME}/.local/share"

  export PATH="${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"
  [[ -d /snap/bin ]] && export PATH="${PATH}:/snap/bin"
  export GOPATH="${HOME}/.local"
  export RLWRAP_HOME="${XDG_CACHE_HOME}/RLWRAP"

  # FZF Defaults
  export FZF_DEFAULT_OPTS='--bind tab:down --bind btab:up --cycle'
  export FZF_DEFAULT_COMMAND="find -L"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

  #  NVIM Defaults
  export NVIM_LOG_FILE="${XDG_CACHE_HOME}/vim/nvim_debug.log"
  export NVIM_RPLUGIN_MANIFESTE="${XDG_CACHE_HOME}/vim/rplugin.vim"

  # Timewarrior
  export TIMEWARRIORDB="${XDG_CACHE_HOME}/timewarrior"

  # docker-compose
  export COMPOSE_PARALLEL_LIMIT=10
  export COMPOSE_HTTP_TIMEOUT=600

  # k9s config directory
  export K9SCONFIG="${XDG_CONFIG_HOME}/k9s"

  # readline config
  export INPUTRC="${XDG_CONFIG_HOME}/readline/inputrc"

  # screen config
  export SCREENRC="${XDG_CONFIG_HOME}/screen/screenrc"

  # wget config
  export WGETRC="${XDG_CONFIG_HOME}/wgetrc"
}


function _nredf_sync_dotfiles() {
  # Load homeshick
if [ ! -d "${HOME}/.homesick" ]; then
  echo -e '\033[1mCloning homesick\033[0m'
  git clone https://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
  source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
  fpath=("${HOME}/.homesick/repos/homeshick/completions ${fpath[@]}")
  echo -e '\033[1mCloning dotfiles\033[0m'
  homeshick --quiet --batch clone https://github.com/NemesisRE/dotfiles.git
  echo -e '\033[1mCloning vimfiles\033[0m'
  homeshick --quiet --batch clone https://github.com/NemesisRE/vimfiles.git
  echo -e '\033[1mLinking dotfiles\033[0m'
  homeshick --quiet --batch --force link
  fc-cache -fv
  exec ${SHELL}
else
  source "${HOME}/.homesick/repos/homeshick/homeshick.sh"
  fpath=("${HOME}/.homesick/repos/homeshick/completions" "${fpath[@]}")
  homeshick --quiet check
  case ${?} in
  86)
    echo -e '\033[1mUpdate and install dotfiles\033[0m'
    homeshick --quiet --batch --force pull
    homeshick --quiet --batch --force link
    exec ${SHELL}
    ;;
  85)
    echo -e '\033[1;38;5;222mYour dotfiles are ahead of its upstream, consider pushing\033[0m'
    ;;
  88)
    echo -e '\033[1;38;5;222mYour dotfiles are modified, commit or discard changes to update them\033[0m'
    ;;
  esac
fi
}

function _nredf_install_fzf() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release junegunn fzf)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/fzf" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/fzf" --version | awk '{print $1}')" ]]; then
    echo -e '\033[1mInstalling fzf\033[0m'
    [[ -d ${HOME}/.fzf ]] && rm -rf "${HOME}/.fzf"
    [[ -f ${HOME}/.fzf.bash ]] && rm -f "${HOME}/.fzf.bash"
    [[ -f ${HOME}/.fzf.zsh ]] && rm -f "${HOME}/.fzf.zsh"
    curl -Lfs "https://github.com/junegunn/fzf/releases/download/${VERSION}/fzf-${VERSION}-${OS}_${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    curl -Lfso "${HOME}/.local/bin/fzf-tmux" "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux"
    [[ ! -d ${HOME}/.config/fzf ]] && /bin/mkdir "${HOME}/.config/fzf"
    for FZF_FILE in completion.bash completion.zsh key-bindings.bash key-bindings.zsh key-bindings.fish; do
      curl -Lfso "${HOME}/.config/fzf/${FZF_FILE}" "https://raw.githubusercontent.com/junegunn/fzf/master/shell/${FZF_FILE}"
    done
    if [[ -f "${HOME}/.local/bin/fzf" ]]; then
      chmod +x "${HOME}/.local/bin/fzf"
    else
      return 1
    fi
    if [[ -f "${HOME}/.local/bin/fzf-tmux" ]]; then
      chmod +x "${HOME}/.local/bin/fzf-tmux"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.config/fzf/completion.${SHELL_NAME}" ]] && source "${HOME}/.config/fzf/completion.${SHELL_NAME}"
    [[ -f "${HOME}/.config/fzf/key-bindings.${SHELL_NAME}" ]] && source "${HOME}/.config/fzf/key-bindings.${SHELL_NAME}"
  fi

  [[ -f "${DOT_PATH}/shell/common/fzf" ]] && source "${DOT_PATH}/shell/common/fzf"
}

function _nredf_install_nvim() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release neovim neovim)

  [[ "${OS}" != "linux" ]] && return 1

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/nvim" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/nvim" --version | head -1 | awk '{print $2}')" ]]; then
    echo -e '\033[1mDownloading neovim\033[0m'
    [[ -d "${HOME}/.cache/vim/squashfs-root" ]] && rm -rf "${HOME}/.cache/vim/squashfs-root"
    [[ -f "${HOME}/.cache/vim/nvim.appimage" ]] && rm -rf "${HOME}/.cache/vim/nvim.appimage"
    curl -Lfso "${HOME}/.cache/vim/nvim.appimage" "https://github.com/neovim/neovim/releases/download/${VERSION}/nvim.appimage"
    if [[ -f "${HOME}/.cache/vim/nvim.appimage" ]]; then
      chmod +x "${HOME}/.cache/vim/nvim.appimage"
    else
      return 1
    fi
    PRERC_CURRENT_DIR=$(pwd)
    cd "${HOME}/.cache/vim/"
    "${HOME}/.cache/vim/nvim.appimage" --appimage-extract &>/dev/null
    cd "${PRERC_CURRENT_DIR}"
    unset PRERC_CURRENT_DIR
    ln -sf "${HOME}/.cache/vim/squashfs-root/AppRun" "${HOME}/.local/bin/nvim"
  fi
}

function _nredf_install_lf() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release gokcehan lf)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/lf" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/lf" -version)" ]]; then
    echo -e '\033[1mInstalling lf\033[0m'
    curl -Lfso - "https://github.com/gokcehan/lf/releases/latest/download/lf-${OS}-${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    if [[ -f "${HOME}/.local/bin/lf" ]]; then
      chmod +x "${HOME}/.local/bin/lf"
    else
      return 1
    fi
  fi

  export LF_ICONS="tw=:st=:ow=:dt=:di=:fi=:ln=:or=:ex=:*.c=:*.cc=:*.clj=:*.coffee=:*.cpp=:*.css=:*.d=:*.dart=:*.erl=:*.exs=:*.fs=:*.go=:*.h=:*.hh=:*.hpp=:*.hs=:*.html=:*.java=:*.jl=:*.js=:*.json=:*.lua=:*.md=:*.php=:*.pl=:*.pro=:*.py=:*.rb=:*.rs=:*.scala=:*.ts=:*.vim=:*.cmd=:*.ps1=:*.sh=:*.bash=:*.zsh=:*.fish=:*.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:*.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:*.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:*.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:*.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:*.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:*.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:*.pcx=:*.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:*.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:*.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:*.ogv=:*.ogx=:*.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:*.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:*.pdf=:*.nix=:"
}

function _nredf_install_lazygit() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release jesseduffield lazygit)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/lazygit" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/lazygit" -v | awk '{print $6}' | awk -F= '{gsub(/,$/,""); print $2}')" ]]; then
    echo -e '\033[1mInstalling lazygit\033[0m'
    curl -Lfso - "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION#v}_${OS}_${UNAMEM}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/" lazygit
    if [[ -f "${HOME}/.local/bin/lazygit" ]]; then
      chmod +x "${HOME}/.local/bin/lazygit"
    else
      return 1
    fi
  fi
}

function _nredf_install_btop() {
  local VERSION
  local LIBC
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release aristocratos btop)
  LIBC="musl"

  if [[ "${OS}" == "linux" ]]; then
    case ${UNAMEM} in
      armv5*) return;;
      armv6*) return;;
      armv7*) LIBC="musleabihf";;
      x86) return;;
      i386) return;;
    esac
  elif [[ "${OS}" == "macos" ]]; then
    LIBC="monterey"
  fi

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/btop" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/btop" -v | awk '{print $3}')" ]]; then
    echo -e '\033[1mInstalling btop\033[0m'
    curl -Lfso - "https://github.com/aristocratos/btop/releases/latest/download/btop-${VERSION#v}-${UNAMEM}-${OS}-${LIBC}.tbz" | tar xjf - -C "${HOME}/.local/bin/" --strip-components=1 --wildcards --no-anchored '*btop'
    if [[ -f "${HOME}/.local/bin/btop" ]]; then
      chmod +x "${HOME}/.local/bin/btop"
    else
      return 1
    fi
  fi
}

function _nredf_install_ctop() {
  if command -pv docker >/dev/null 2>&1; then
    return 0
  fi
  local VERSION

  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release bcicen ctop)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/ctop" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/ctop" -v | awk '{sub(",",""); print $3}')" ]]; then
    echo -e '\033[1mInstalling ctop\033[0m'
    curl -Lfso "${HOME}/.local/bin/ctop" "https://github.com/bcicen/ctop/releases/latest/download/ctop-${VERSION#v}-${OS}-${ARCH}"
    if [[ -f "${HOME}/.local/bin/ctop" ]]; then
      chmod +x "${HOME}/.local/bin/ctop"
    else
      return 1
    fi
  fi
}

function _nredf_install_drone() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release harness drone-cli)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/drone" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/drone" -v | awk '{print $3}')" ]]; then
    echo -e '\033[1mInstalling drone\033[0m'
    curl -Lfso - "https://github.com/harness/drone-cli/releases/latest/download/drone_${OS}_${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    if [[ -f "${HOME}/.local/bin/drone" ]]; then
      chmod +x "${HOME}/.local/bin/drone"
    else
      return 1
    fi
  fi
}

function _nredf_install_zellij() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release zellij-org zellij)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/zellij" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/zellij" -V | awk '{print $2}')" ]]; then
    echo -e '\033[1mInstalling zellij\033[0m'
    curl -Lfso - "https://github.com/zellij-org/zellij/releases/latest/download/zellij-${UNAMEM}-${PLATFORM}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    if [[ -f "${HOME}/.local/bin/zellij" ]]; then
      chmod +x "${HOME}/.local/bin/zellij"
    else
      return 1
    fi
  fi

  #if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
  #  [[ -f "${HOME}/.local/bin/zellij" ]] && source <("${HOME}/.local/bin/zellij" setup --generate-completion ${SHELL_NAME})
  #fi
}

function _nredf_install_ripgrep() {
  _nredf_get_sys_info
  local VERSION
  local GHUSER
  local GHREPO
  local BINARY
  local BINARY_VERSION

  GHUSER="BurntSushi"
  GHREPO="ripgrep"
  BINARY="rg"
  VERSION=$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")
  BINARY_VERSION="--version | awk '/ripgrep/{print $2}'"

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/${BINARY}" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/${BINARY}" "${BINARY_VERSION}")" ]]; then
    echo -e "\033[1mInstalling ${GHREPO}\033[0m"
    _nredf_github_download_latest "${GHUSER}" "${GHREPO}" "ripgrep-${VERSION}-${UNAMEM}-${PLATFORM}.tar.gz"
    tar -xzf "${XDG_CACHE_HOME}/nredf/Download/ripgrep-${VERSION}-${UNAMEM}-${PLATFORM}.tar.gz" -C "${XDG_CACHE_HOME}/nredf/Download/"
    cp "${XDG_CACHE_HOME}/nredf/Download/ripgrep-${VERSION}-${UNAMEM}-${PLATFORM}/${BINARY}" "${HOME}/.local/bin/"
    if [[ -f "${HOME}/.local/bin/${BINARY}" ]]; then
      chmod +x "${HOME}/.local/bin/${BINARY}"
    else
      return 1
    fi
  fi
}

function _nredf_install_k8s_ops() {
  _nredf_install_kubectl
  _nredf_install_krew
  _nredf_install_kubeadm
  _nredf_install_kubeseal
  _nredf_install_fluxctl
  _nredf_install_flux
  _nredf_install_helm
  _nredf_install_k9s
  _nredf_install_velero
}

function _nredf_install_kubectl() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

  if [[ ! -f "${HOME}/.local/bin/kubectl" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/kubectl" version --short --client | awk '{print $3}')" ]]; then
    echo -e '\033[1mInstalling kubectl\033[0m'
    [[ -f "${HOME}/.local/bin/kubectl" ]] && rm -f "${HOME}/.local/bin/kubectl"
    curl -Lfso "${HOME}/.local/bin/kubectl" "https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubectl"
    if [[ -f "${HOME}/.local/bin/kubectl" ]]; then
      chmod +x "${HOME}/.local/bin/kubectl"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/kubectl" ]] && source <("${HOME}/.local/bin/kubectl" completion "${SHELL_NAME}")
  fi
}

function _nredf_install_krew() {
  local VERSION
  [[ ! -f "${HOME}/.local/bin/kubectl" ]] && return 1

  VERSION=$(_nredf_github_latest_release kubernetes-sigs krew)

  export KREW_PLUGINS=()
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  if [[ ! -d "${HOME}/.krew" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/kubectl" krew version | awk '/^GitTag/{print $2}')" ]]; then
    echo -e '\033[1mInstalling krew\033[0m'
    curl -LfsSo "${HOME}/.cache/krew/krew.tar.gz" "https://github.com/kubernetes-sigs/krew/releases/download/${VERSION}/krew.tar.gz"
    if [[ -f "${HOME}/.cache/krew/krew.tar.gz" ]]; then
      tar -zxf "${HOME}/.cache/krew/krew.tar.gz" --directory "${HOME}/.cache/krew"
      rm -f "${HOME}/.cache/krew/krew.tar.gz"
      KREW="${HOME}/.cache/krew/krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')""
      "$KREW" install krew 2>/dev/null
    else
      return 1
    fi
  fi

  echo -e '\033[1mUpdating krew plugins\033[0m'
  kubectl krew update 2>/dev/null
  kubectl krew upgrade 2>/dev/null

  KREW_PLUGINS+=("ctx")
  KREW_PLUGINS+=("ns")
  KREW_PLUGINS+=("doctor")
  KREW_PLUGINS+=("fuzzy")
  KREW_PLUGINS+=("konfig")
  KREW_PLUGINS+=("images")
  KREW_PLUGINS+=("status")
  KREW_PLUGINS+=("oidc-login")
  KREW_PLUGINS+=("get-all")
  KREW_PLUGINS+=("resource-capacity")
  KREW_PLUGINS+=("deprecations")
  KREW_PLUGINS+=("df-pv")
  KREW_PLUGINS+=("outdated")
  KREW_PLUGINS+=("sniff")

  for KREW_PLUGIN in "${KREW_PLUGINS[@]}"; do
    kubectl krew list | grep -q "${KREW_PLUGIN}" || kubectl krew install "${KREW_PLUGIN}" 2>/dev/null
  done
}

function _nredf_install_kubeadm() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

  if [[ ! -f "${HOME}/.local/bin/kubeadm" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/kubeadm" version -o short)" ]]; then
    echo -e '\033[1mInstalling kubeadm\033[0m'
    [[ -f "${HOME}/.local/bin/kubeadm" ]] && rm -f "${HOME}/.local/bin/kubeadm"
    curl -Lfso "${HOME}/.local/bin/kubeadm" "https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubeadm"
    if [[ -f "${HOME}/.local/bin/kubeadm" ]]; then
      chmod +x "${HOME}/.local/bin/kubeadm"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/kubeadm" ]] && source <("${HOME}/.local/bin/kubeadm" completion "${SHELL_NAME}")
  fi
}

function _nredf_install_kubeseal() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release bitnami-labs sealed-secrets)

  if [[ ! -f "${HOME}/.local/bin/kubeseal" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/kubeseal" --version | awk '{print $3}')" ]]; then
    echo -e '\033[1mInstalling kubeseal\033[0m'
    [[ -f "${HOME}/.local/bin/kubeseal" ]] && rm -f "${HOME}/.local/bin/kubeseal"
    curl -Lfso "${HOME}/.local/bin/kubeseal" "https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-${OS}-${ARCH}"
    if [[ -f "${HOME}/.local/bin/kubeseal" ]]; then
      chmod +x "${HOME}/.local/bin/kubeseal"
    else
      return 1
    fi
  fi
}

function _nredf_install_fluxctl() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release fluxcd flux)

  if [[ ! -f "${HOME}/.local/bin/fluxctl" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/fluxctl" version)" ]]; then
    echo -e '\033[1mInstalling fluxctl\033[0m'
    [[ -f "${HOME}/.local/bin/fluxctl" ]] && rm -f "${HOME}/.local/bin/fluxctl"
    curl -Lfso "${HOME}/.local/bin/fluxctl" "https://github.com/fluxcd/flux/releases/latest/download/fluxctl_${OS}_${ARCH}"
    if [[ -f "${HOME}/.local/bin/fluxctl" ]]; then
      chmod +x "${HOME}/.local/bin/fluxctl"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/fluxctl" ]] && source <("${HOME}/.local/bin/fluxctl" completion "${SHELL_NAME}")
  fi
}

function _nredf_install_flux() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release fluxcd flux2)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/flux" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$("${HOME}/.local/bin/flux" --version | awk '{print $3}')" ]]; then
    echo -e '\033[1mInstalling flux\033[0m'
    [[ -f "${HOME}/.local/bin/flux" ]] && rm -f "${HOME}/.local/bin/flux"
    curl -Lfso - "https://github.com/fluxcd/flux2/releases/latest/download/flux_${VERSION#v}_${OS}_${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    if [[ -f "${HOME}/.local/bin/flux" ]]; then
      chmod +x "${HOME}/.local/bin/flux"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/flux" ]] && source <("${HOME}/.local/bin/flux" completion "${SHELL_NAME}")
  fi
}

function _nredf_install_helm() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release helm helm)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/helm" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/helm" version --template\='{{ .Version }}')" ]]; then
    echo -e '\033[1mInstalling helm\033[0m'
    [[ -f "${HOME}/.local/bin/helm" ]] && rm -f "${HOME}/.local/bin/helm"
    curl -Lfso - "https://get.helm.sh/helm-${VERSION}-${OS}-${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/" --strip-components=1 --wildcards --no-anchored '*helm'
    if [[ -f "${HOME}/.local/bin/helm" ]]; then
      chmod +x "${HOME}/.local/bin/helm"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/helm" ]] && source <("${HOME}/.local/bin/helm" completion "${SHELL_NAME}")
  fi
}

function _nredf_install_k9s() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release derailed k9s)

  if [[ ! -f "${HOME}/.local/bin/k9s" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/k9s" version -s | awk 'tolower($0) ~ /version/{print $2}')" ]]; then
    echo -e '\033[1mInstalling k9s\033[0m'
    [[ -f "${HOME}/.local/bin/k9s" ]] && rm -f "${HOME}/.local/bin/k9s"
    curl -Lfso - "https://github.com/derailed/k9s/releases/latest/download/k9s_$(uname)_${UNAMEM}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/" k9s
    if [[ -f "${HOME}/.local/bin/k9s" ]]; then
      chmod +x "${HOME}/.local/bin/k9s"
    else
      return 1
    fi
  fi
}

function _nredf_install_velero() {
  local VERSION
  _nredf_get_sys_info

  VERSION=$(_nredf_github_latest_release vmware-tanzu velero)

  if [[ ! -f "${HOME}/.local/bin/velero" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$("${HOME}/.local/bin/velero" version --client-only | grep Version | awk '{print $2}')" ]]; then
    echo -e '\033[1mInstalling velero\033[0m'
    [[ -f "${HOME}/.local/bin/velero" ]] && rm -f "${HOME}/.local/bin/velero"
    curl -Lfso - "https://github.com/vmware-tanzu/velero/releases/latest/download/velero-${VERSION}-${OS}-${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/" --strip-components=1 --wildcards --no-anchored '*velero'
    if [[ -f "${HOME}/.local/bin/velero" ]]; then
      chmod +x "${HOME}/.local/bin/velero"
    else
      return 1
    fi
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${HOME}/.local/bin/velero" ]] && source <("${HOME}/.local/bin/velero" completion "${SHELL_NAME}")
  fi
}
