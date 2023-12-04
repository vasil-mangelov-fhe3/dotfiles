function _nredf_create_completion() {
  local BINARY=${1}
  local COMPLETION_CMD=${2}
  local COMPLETION_FILE

  case ${NREDF_SHELL_NAME} in
    bash) COMPLETION_FILE="${BINARY}.bash";;
    zsh) COMPLETION_FILE="_${BINARY}";;
    *) return 1;;
  esac

  if [[ -f "${XDG_BIN_HOME}/${BINARY}" ]]; then
    "${XDG_BIN_HOME}/${BINARY}" "${COMPLETION_CMD}" 2>/dev/null > "${XDG_CONFIG_HOME}/completion/${NREDF_SHELL_NAME}/${COMPLETION_FILE}"
  else
    return 1
  fi

}
