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
