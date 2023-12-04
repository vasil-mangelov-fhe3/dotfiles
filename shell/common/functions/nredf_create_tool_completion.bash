#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2086

function _nredf_create_tool_completion() {
  local BINARY="${1}"
  local COMPLETION_CMD="${2}"
  local COMPLETION_FILE

  case "${NREDF_SHELL_NAME}" in
    bash) COMPLETION_FILE="${BINARY}.bash";;
    zsh) COMPLETION_FILE="_${BINARY}";;
    *) return 1;;
  esac

  if [[ -f "${XDG_BIN_HOME}/${BINARY}" ]]; then
    if "${XDG_BIN_HOME}/${BINARY}" ${COMPLETION_CMD} &>/dev/null; then
      "${XDG_BIN_HOME}/${BINARY}" ${COMPLETION_CMD} 2>/dev/null > "${XDG_CONFIG_HOME}/completion/${NREDF_SHELL_NAME}/${COMPLETION_FILE}"
    else
      return 1
    fi
  else
    return 1
  fi
}
