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

  OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')
  case "${OS}" in
    mingw*) OS='windows';;
  esac

  export ARCH OS
}

function _nredf_github_latest_release() {
  local GHUSER=${1}
  local GHREPO=${2}

  GH_LATEST_RELEASE=$(curl -s https://api.github.com/repos/${GHUSER}/${GHREPO}/releases/latest | grep -Po '"tag_name":"\K.*?(?=")')

  echo ${GH_LATEST_RELEASE}
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

function _nredf_install_nvim() {
  _nredf_get_sys_info

  [[ "${OS}" != "linux" ]] && return 1
  if [[ ! -f "${HOME}/.local/bin/nvim" ]] || [[ "$(${HOME}/.local/bin/nvim --version | head -1)" != "$(curl -sH 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/neovim/neovim/releases/tags/nightly | grep -Po '"name":"\K.*?(?=")' | head -1)" ]]; then
    echo -e '\033[1mDownloading neovim\033[0m'
    [[ -d "${HOME}/.cache/vim/squashfs-root" ]] && rm -rf "${HOME}/.cache/vim/squashfs-root"
    [[ -f "${HOME}/.cache/vim/nvim.appimage" ]] && rm -rf "${HOME}/.cache/vim/nvim.appimage"
    curl -Lso "${HOME}/.cache/vim/nvim.appimage" "https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage"
    chmod +x "${HOME}/.cache/vim/nvim.appimage"
    PRERC_CURRENT_DIR=$(pwd)
    cd "${HOME}/.cache/vim/"
    ${HOME}/.cache/vim/nvim.appimage --appimage-extract &>/dev/null
    cd ${PRERC_CURRENT_DIR}
    unset PRERC_CURRENT_DIR
    ln -sf "${HOME}/.cache/vim/squashfs-root/AppRun" "${HOME}/.local/bin/nvim"
  fi
}

function _nredf_install_lf() {
  _nredf_get_sys_info

  if [[ ! -f "${HOME}/.local/bin/lf" ]] || [[ "$(_nredf_github_latest_release gokcehan lf)" != "$(${HOME}/.local/bin/lf -version)" ]]; then
    echo -e '\033[1mInstalling lf\033[0m'
    curl -Ls "https://github.com/gokcehan/lf/releases/latest/download/lf-${OS}-${ARCH}.tar.gz" | tar xzf - -C ${HOME}/.local/bin/
    chmod +x ${HOME}/.local/bin/lf
  fi
}

function _nredf_install_k8s_ops() {
  _nredf_get_sys_info

  if [[ ! -f "${HOME}/.local/bin/kubectl" ]] || [[ $(curl -L -s https://dl.k8s.io/release/stable.txt) != $(${HOME}/.local/bin/kubectl version --short --client | awk -F: '{ gsub(/ /,""); print $2}') ]]; then
    echo -e '\033[1mInstalling kubectl\033[0m'
    curl -Ls "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl" -o ${HOME}/.local/bin/kubectl
    chmod +x ${HOME}/.local/bin/kubectl
  fi

  if [[ ! -d "${HOME}/.krew" ]]; then
    echo -e '\033[1mInstalling krew\033[0m'
    curl -fsSLo ${HOME}/.cache/krew/krew.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz"
    tar -zxf ${HOME}/.cache/krew/krew.tar.gz --directory ${HOME}/.cache/krew && rm -f ${HOME}/.cache/krew/krew.tar.gz
    KREW=${HOME}/.cache/krew/krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')"
    "$KREW" install krew 2>/dev/null
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  else
    echo -e '\033[1mUpdating krew and plugins\033[0m'
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    kubectl krew update 2>/dev/null
    kubectl krew upgrade 2>/dev/null
    for KREW_PLUGIN in ctx ns doctor fuzzy images status oidc-login; do
      kubectl krew list | grep -q ${KREW_PLUGIN} || kubectl krew install ${KREW_PLUGIN} 2>/dev/null
    done
  fi

  if [[ ! -f "${HOME}/.local/bin/fluxctl" ]] || [[ ! "$(_nredf_github_latest_release fluxcd flux)" == "$(${HOME}/.local/bin/fluxctl version)" ]]; then
    echo -e '\033[1mInstalling fluxctl\033[0m'
    [[ -f "${HOME}/.local/bin/fluxctl" ]] && rm -f "${HOME}/.local/bin/fluxctl"
    curl -sL https://github.com/fluxcd/flux/releases/latest/download/fluxctl_${OS}_${ARCH} -o ${HOME}/.local/bin/fluxctl
    chmod +x ${HOME}/.local/bin/fluxctl
  fi

  echo -e '\033[1mRunning get_helm\033[0m'
  curl -fsSL -o ${HOME}/.cache/helm/get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
  chmod +x ${HOME}/.cache/helm/get_helm.sh
  HELM_INSTALL_DIR="${HOME}/.local/bin" ${HOME}/.cache/helm/get_helm.sh --no-sudo >/dev/null

  if [[ ! -f "${HOME}/.local/bin/k9s" ]] || [[ ! "$(_nredf_github_latest_release derailed k9s)" == "$(${HOME}/.local/bin/k9s version | grep Version | awk '{print $2}')" ]]; then
    echo -e '\033[1mInstalling k9s\033[0m'
    [[ -f "${HOME}/.local/bin/k9s" ]] && rm -f "${HOME}/.local/bin/k9s"
    curl -Ls "https://github.com/derailed/k9s/releases/latest/download/k9s_$(uname)_$(uname -m).tar.gz" | tar xzf - -C ${HOME}/.local/bin/ k9s
    chmod +x ${HOME}/.local/bin/k9s
  fi
}

