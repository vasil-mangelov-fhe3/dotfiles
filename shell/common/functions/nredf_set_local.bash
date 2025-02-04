#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

_nredf_set_local () {
  echo -e '\033[1mSourcing local aliases and functions\033[0m'

  if [[ ! -d "${NREDF_RC_LOCAL}" ]]; then
    mkdir -p "${NREDF_RC_LOCAL}"
  fi

  if [[ -e "${NREDF_DOT_PATH}/shell/common/aliases" ]]; then
    source "${NREDF_DOT_PATH}/shell/common/aliases"
  fi

  if [[ -e "${NREDF_RC_PATH}/aliases" ]]; then
    source "${NREDF_RC_PATH}/aliases"
  fi

  if [[ -f "${NREDF_RC_LOCAL}/aliases.local" ]]; then
    source "${NREDF_RC_LOCAL}/aliases.local"
  else
    touch "${NREDF_RC_LOCAL}/aliases.local"
  fi

  if [[ -e "${NREDF_RC_PATH}/functions" ]]; then
    source "${NREDF_RC_PATH}/functions"
  fi

  if [[ -f "${NREDF_RC_LOCAL}/functions.local" ]]; then
    source "${NREDF_RC_LOCAL}/functions.local"
  else
    touch "${NREDF_RC_LOCAL}/functions.local"
  fi

  if [[ -f "${NREDF_COMMON_RC_LOCAL}/rc.local" ]]; then
    source "${NREDF_COMMON_RC_LOCAL}/rc.local"
  else
    touch "${NREDF_COMMON_RC_LOCAL}/rc.local"
  fi

  if [[ -f "${NREDF_RC_LOCAL}/rc.local" ]]; then
    source "${NREDF_RC_LOCAL}/rc.local"
  else
    touch "${NREDF_RC_LOCAL}/rc.local"
  fi
}
