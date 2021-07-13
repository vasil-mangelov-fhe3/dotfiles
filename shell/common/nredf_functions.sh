#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_set_ssh_agent() {
  if [[ -z ${SSH_CONNECTION} && "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    unset SSH_AGENT_PID
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  fi
}

function _nredf_get_sys_info() {
  ARCH=$(uname -m)
  case ${ARCH} in
    armv5*) ARCH="armv5";;
    armv6*) ARCH="armv6";;
    armv7*) ARCH="arm";;
    aarch64) ARCH="arm64";;
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac

  OS=$(uname|tr '[:upper:]' '[:lower:]')
  case "${OS}" in
    mingw*) OS='windows';;
  esac

  export ARCH OS
}

function _nredf_github_latest_release() {
  local GHUSER=${1}
  local GHREPO=${2}

  GH_LATEST_RELEASE=$(curl -s "https://api.github.com/repos/${GHUSER}/${GHREPO}/releases/latest" | grep -Po '"tag_name":"\K.*?(?=")')

  echo "${GH_LATEST_RELEASE}"
}

function _nredf_set_defaults() {
  # You may need to manually set your language environment
  export LANG=en_US.UTF-8
  export LANGUAGE=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

  export PATH=${HOME}/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}
  [[ -d /snap/bin ]] && export PATH=${PATH}:/snap/bin
  export GOPATH=${HOME}/.local
  export RLWRAP_HOME=${HOME}/.cache/RLWRAP

  # FZF Defaults
  export FZF_DEFAULT_OPTS='--bind tab:down --bind btab:up --cycle'
  export FZF_DEFAULT_COMMAND="find -L"
  export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

  #  NVIM Defaults
  export NVIM_LOG_FILE="${HOME}/.cache/vim/nvim_debug.log"
  export NVIM_RPLUGIN_MANIFESTE="${HOME}/.cache/vim/rplugin.vim"

  # Timewarrior
  export TIMEWARRIORDB="${HOME}/.cache/timewarrior"

  # docker-compose
  export COMPOSE_PARALLEL_LIMIT=10
  export COMPOSE_HTTP_TIMEOUT=600
}

function _nredf_install_fzf() {
  _nredf_get_sys_info
  local VERSION=$(_nredf_github_latest_release junegunn fzf)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  if [[ ! -f "${HOME}/.local/bin/fzf" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$(${HOME}/.local/bin/fzf --version | awk '{print $1}')" ]]; then
    echo -e '\033[1mInstalling fzf\033[0m'
    [[ -d ${HOME}/.fzf ]] && rm -rf "${HOME}/.fzf"
    [[ -f ${HOME}/.fzf.bash ]] && rm -f "${HOME}/.fzf.bash"
    [[ -f ${HOME}/.fzf.zsh ]] && rm -f "${HOME}/.fzf.zsh"
    curl -Ls "https://github.com/junegunn/fzf/releases/download/${VERSION}/fzf-${VERSION}-${OS}_${ARCH}.tar.gz" | tar xzf - -C "${HOME}/.local/bin/"
    curl -Ls "https://raw.githubusercontent.com/junegunn/fzf/master/bin/fzf-tmux" -o "${HOME}/.local/bin/fzf-tmux"
    [[ ! -d ${HOME}/.config/fzf ]] && /bin/mkdir "${HOME}/.config/fzf"
    for FZF_FILE in completion.bash completion.zsh key-bindings.bash key-bindings.zsh key-bindings.fish; do
      curl -Ls "https://raw.githubusercontent.com/junegunn/fzf/master/shell/${FZF_FILE}" -o "${HOME}/.config/fzf/${FZF_FILE}"
    done
    chmod +x ${HOME}/.local/bin/fzf ${HOME}/.local/bin/fzf-tmux
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f ${HOME}/.config/fzf/completion.${SHELL_NAME} ]] && source "${HOME}/.config/fzf/completion.${SHELL_NAME}"
    [[ -f ${HOME}/.config/fzf/key-bindings.${SHELL_NAME} ]] && source "${HOME}/.config/fzf/key-bindings.${SHELL_NAME}"
  fi

  [[ -f "${DOT_PATH}/shell/common/fzf" ]] && source "${DOT_PATH}/shell/common/fzf"
}

function _nredf_install_nvim() {
  _nredf_get_sys_info
  local VERSION=$(curl -sH 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/neovim/neovim/releases/tags/nightly | grep -Po '"name":"\K.*?(?=")' | head -1)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  [[ "${OS}" != "linux" ]] && return 1

  if [[ ! -f "${HOME}/.local/bin/nvim" ]] || [[ "${VERSION}" != "" && ${VERSION} != $(${HOME}/.local/bin/nvim --version | head -1) ]]; then
    echo -e '\033[1mDownloading neovim\033[0m'
    [[ -d "${HOME}/.cache/vim/squashfs-root" ]] && rm -rf "${HOME}/.cache/vim/squashfs-root"
    [[ -f "${HOME}/.cache/vim/nvim.appimage" ]] && rm -rf "${HOME}/.cache/vim/nvim.appimage"
    curl -Lso "${HOME}/.cache/vim/nvim.appimage" "https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
    chmod +x "${HOME}/.cache/vim/nvim.appimage"
    PRERC_CURRENT_DIR=$(pwd)
    cd "${HOME}/.cache/vim/"
    ${HOME}/.cache/vim/nvim.appimage --appimage-extract &>/dev/null
    cd "${PRERC_CURRENT_DIR}"
    unset PRERC_CURRENT_DIR
    ln -sf "${HOME}/.cache/vim/squashfs-root/AppRun" "${HOME}/.local/bin/nvim"
  fi
}

function _nredf_install_lf() {
  _nredf_get_sys_info

  local VERSION=$(_nredf_github_latest_release gokcehan lf)

  if [[ ! -f "${HOME}/.local/bin/lf" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$(${HOME}/.local/bin/lf -version)" ]]; then
    echo -e '\033[1mInstalling lf\033[0m'
    curl -Ls "https://github.com/gokcehan/lf/releases/latest/download/lf-${OS}-${ARCH}.tar.gz" | tar xzf - -C ${HOME}/.local/bin/
    chmod +x ${HOME}/.local/bin/lf
  fi

  export LF_ICONS="tw=:st=:ow=:dt=:di=:fi=:ln=:or=:ex=:*.c=:*.cc=:*.clj=:*.coffee=:*.cpp=:*.css=:*.d=:*.dart=:*.erl=:*.exs=:*.fs=:*.go=:*.h=:*.hh=:*.hpp=:*.hs=:*.html=:*.java=:*.jl=:*.js=:*.json=:*.lua=:*.md=:*.php=:*.pl=:*.pro=:*.py=:*.rb=:*.rs=:*.scala=:*.ts=:*.vim=:*.cmd=:*.ps1=:*.sh=:*.bash=:*.zsh=:*.fish=:*.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:*.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:*.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:*.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:*.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:*.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:*.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:*.pcx=:*.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:*.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:*.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:*.ogv=:*.ogx=:*.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:*.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:*.pdf=:*.nix=:"
}

function _nredf_install_lazygit() {
  _nredf_get_sys_info

  local VERSION=$(_nredf_github_latest_release jesseduffield lazygit)

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/lazygit" ]] || [[ "${VERSION}" != "" && "${VERSION#v}" != "$(${HOME}/.local/bin/lazygit -v | awk '{print $6}' | awk -F= '{gsub(/,$/,""); print $2}')" ]]; then
    echo -e '\033[1mInstalling lazygit\033[0m'
    curl -Ls "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${VERSION#v}_${OS}_$(uname -m).tar.gz" | tar xzf - -C ${HOME}/.local/bin/ lazygit
    chmod +x ${HOME}/.local/bin/lazygit
  fi

  alias lg=lazygit
}

function _nredf_install_k8s_ops() {
  _nredf_install_kubectl
  _nredf_install_krew
  _nredf_install_kubeadm
  _nredf_install_kubeseal
  _nredf_install_fluxcd
  _nredf_install_helm
  _nredf_install_k9s
}

function _nredf_install_kubectl() {
  _nredf_get_sys_info
  local VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  if [[ ! -f "${HOME}/.local/bin/kubectl" ]] || [[ "${VERSION}" != "" && ${VERSION} != $(${HOME}/.local/bin/kubectl version --short --client | awk '{print $3}') ]]; then
    echo -e '\033[1mInstalling kubectl\033[0m'
    [[ -f "${HOME}/.local/bin/kubectl" ]] && rm -f "${HOME}/.local/bin/kubectl"
    curl -Ls "https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubectl" -o ${HOME}/.local/bin/kubectl
    chmod +x ${HOME}/.local/bin/kubectl
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f ${HOME}/.local/bin/kubectl ]] && source <(${HOME}/.local/bin/kubectl completion ${SHELL_NAME})
  fi
}

function _nredf_install_krew() {
  [[ ! -f "${HOME}/.local/bin/kubectl" ]] && return 1

  local VERSION=$(_nredf_github_latest_release kubernetes-sigs krew)

  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

  if [[ ! -d "${HOME}/.krew" ]] || [[ "${VERSION}" != "" && ${VERSION} != $(${HOME}/.local/bin/kubectl krew version | awk '/^GitTag/{print $2}') ]]; then
    echo -e '\033[1mInstalling krew\033[0m'
    curl -fsSLo ${HOME}/.cache/krew/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/download/${VERSION}/krew.tar.gz"
    tar -zxf ${HOME}/.cache/krew/krew.tar.gz --directory ${HOME}/.cache/krew && rm -f ${HOME}/.cache/krew/krew.tar.gz
    KREW=${HOME}/.cache/krew/krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')"
    "$KREW" install krew 2>/dev/null
  fi

  echo -e '\033[1mUpdating krew plugins\033[0m'
  kubectl krew upgrade 2>/dev/null
  for KREW_PLUGIN in ctx ns doctor fuzzy konfig images status oidc-login get-all; do
    kubectl krew list | grep -q ${KREW_PLUGIN} || kubectl krew install ${KREW_PLUGIN} 2>/dev/null
  done
}

function _nredf_install_kubeadm() {
  _nredf_get_sys_info
  local VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  if [[ ! -f "${HOME}/.local/bin/kubeadm" ]] || [[ "${VERSION}" != "" && ${VERSION} != $(${HOME}/.local/bin/kubeadm version -o short) ]]; then
    echo -e '\033[1mInstalling kubeadm\033[0m'
    [[ -f "${HOME}/.local/bin/kubeadm" ]] && rm -f "${HOME}/.local/bin/kubeadm"
    curl -Ls "https://dl.k8s.io/release/${VERSION}/bin/${OS}/${ARCH}/kubeadm" -o ${HOME}/.local/bin/kubeadm
    chmod +x ${HOME}/.local/bin/kubeadm
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f ${HOME}/.local/bin/kubeadm ]] && source <(${HOME}/.local/bin/kubeadm completion ${SHELL_NAME})
  fi
}

function _nredf_install_kubeseal() {
  _nredf_get_sys_info
  local VERSION=$(_nredf_github_latest_release bitnami-labs sealed-secrets)

  if [[ ! -f "${HOME}/.local/bin/kubeseal" ]] || [[ "${VERSION}" != "" && ${VERSION} != $(${HOME}/.local/bin/kubeseal --version | awk '{print $3}') ]]; then
    echo -e '\033[1mInstalling kubeseal\033[0m'
    [[ -f "${HOME}/.local/bin/kubeseal" ]] && rm -f "${HOME}/.local/bin/kubeseal"
    curl -Ls "https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-${OS}-${ARCH}" -o ${HOME}/.local/bin/kubeseal
    chmod +x ${HOME}/.local/bin/kubeseal
  fi
}

function _nredf_install_fluxcd() {
  _nredf_get_sys_info
  local VERSION=$(_nredf_github_latest_release fluxcd flux)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  if [[ ! -f "${HOME}/.local/bin/fluxctl" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$(${HOME}/.local/bin/fluxctl version)" ]]; then
    echo -e '\033[1mInstalling fluxctl\033[0m'
    [[ -f "${HOME}/.local/bin/fluxctl" ]] && rm -f "${HOME}/.local/bin/fluxctl"
    curl -sL https://github.com/fluxcd/flux/releases/latest/download/fluxctl_${OS}_${ARCH} -o ${HOME}/.local/bin/fluxctl
    chmod +x ${HOME}/.local/bin/fluxctl
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f ${HOME}/.local/bin/fluxctl ]] && source <(${HOME}/.local/bin/fluxctl completion ${SHELL_NAME})
  fi
}

function _nredf_install_helm() {
  _nredf_get_sys_info
  local VERSION=$(_nredf_github_latest_release helm helm)
  local SHELL_NAME=$(readlink /proc/$$/exe | awk -F'/' '{print $NF}')

  if [[ "${VERSION}" != "" && ! -f "${HOME}/.local/bin/helm" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$(${HOME}/.local/bin/helm version --template='{{ .Version }}')" ]]; then
    echo -e '\033[1mInstalling helm\033[0m'
    [[ -f "${HOME}/.local/bin/helm" ]] && rm -f "${HOME}/.local/bin/helm"
    echo "curl -sL https://get.helm.sh/helm-${VERSION}-${OS}-${ARCH}.tar.gz | tar xzf - -C ${HOME}/.cache/helm"
    mv ${HOME}/.cache/helm/**/helm ${HOME}/.local/bin/helm
    chmod +x ${HOME}/.local/bin/helm
  fi

  if [[ "${SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f ${HOME}/.local/bin/helm ]] && source <(${HOME}/.local/bin/helm completion ${SHELL_NAME})
  fi
}

function _nredf_install_k9s() {
  _nredf_get_sys_info
  local VERSION=$(_nredf_github_latest_release derailed k9s)

  if [[ ! -f "${HOME}/.local/bin/k9s" ]] || [[ "${VERSION}" != "" && "${VERSION}" != "$(${HOME}/.local/bin/k9s version | grep Version | awk '{print $2}' | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g")" ]]; then
    echo -e '\033[1mInstalling k9s\033[0m'
    [[ -f "${HOME}/.local/bin/k9s" ]] && rm -f "${HOME}/.local/bin/k9s"
    curl -Ls "https://github.com/derailed/k9s/releases/latest/download/k9s_$(uname)_$(uname -m).tar.gz" | tar xzf - -C ${HOME}/.local/bin/ k9s
    chmod +x ${HOME}/.local/bin/k9s
  fi
}
