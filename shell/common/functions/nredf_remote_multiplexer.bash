#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_remote_multiplexer() {
  if [[ "${TERM_PROGRAM}" != "vscode" ]]; then
    if [[ -n "${SSH_TTY}" || -n "${WSL_DISTRO_NAME}" ]] && command -v zellij &>/dev/null; then
      if [[ -z "${ZELLIJ}" ]]; then
        echo -e "\033[1mStarting multiplexer\033[0m"
        if [[ -n "${SSH_AUTH_SOCK}" ]] && [[ "${SSH_AUTH_SOCK}" != "${HOME}/.ssh/agent_sock" ]]; then
            unlink "${HOME}/.ssh/auth_sock" 2>/dev/null
            ln -sf "${SSH_AUTH_SOCK}" "${HOME}/.ssh/auth_sock"
            export SSH_AUTH_SOCK="${HOME}/.ssh/auth_sock"
        fi
        zellij attach -c "$(hostname -s)"
      fi
    elif [[ "${NREDF_OS}" == "linux" ]] && [[ -n "${SSH_TTY}" ]] && [[ "${PS1}" != "" ]] && command -pv tmux &>/dev/null; then
      if [[ -z "${TMUX}" ]]; then
        if [ -n "${SSH_AUTH_SOCK}" ] && [ "${SSH_AUTH_SOCK}" != "${HOME}/.ssh/agent_sock" ]; then
            unlink "${HOME}/.ssh/auth_sock" 2>/dev/null
            ln -sf "${SSH_AUTH_SOCK}" "${HOME}/.ssh/auth_sock"
            export SSH_AUTH_SOCK="${HOME}/.ssh/auth_sock"
        fi
              # Start tmux on connection
        if [[ "$(tmux -L "$(hostname -s)" has-session -t "$(hostname -s)" &>/dev/null; echo $?)" = 0 ]]; then
            echo -e '\033[1mAttach to running tmux session\033[0m'
            tmux -L "$(hostname -s)" attach-session -t "$(hostname -s)"
        elif [[ "$(which tmux 2>/dev/null)" != "" ]] && [[ "${TMUX}" = "" ]]; then
            echo -e '\033[1mStart new tmux session\033[0m'
            tmux -L "$(hostname -s)" new-session -s "$(hostname -s)"
        fi
      fi
    fi
  fi
}
