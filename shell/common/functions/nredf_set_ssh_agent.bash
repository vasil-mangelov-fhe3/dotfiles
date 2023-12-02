#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_set_ssh_agent() {
  if ! command -v gpgconf &>/dev/null; then
    return 1
  fi
  if [[ -z ${SSH_CONNECTION} && "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]]; then
    unset SSH_AGENT_PID
    SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    export SSH_AUTH_SOCK
  fi
}
