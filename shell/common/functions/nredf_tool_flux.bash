#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_flux() {
  _nredf_get_sys_info

  local GHUSER="fluxcd"
  local GHREPO="flux2"
  local BINARY="flux"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}_${VERSION}_${NREDF_UNAME_LOWER}_${NREDF_ARCH}.tar.gz"
  local VERSION_CMD="--version | awk '{print \$3}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    tar -xzf "${NREDF_DOWNLOADS}/${FILENAME}" -C "${XDG_BIN_HOME}/" "${BINARY}"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"

  if [[ "${NREDF_SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${XDG_BIN_HOME}/${BINARY}" ]] && "${XDG_BIN_HOME}/${BINARY}" completion "${NREDF_SHELL_NAME}" > "${XDG_CONFIG_HOME}/completion/${NREDF_SHELL_NAME}/_${BINARY}"
  fi
}
