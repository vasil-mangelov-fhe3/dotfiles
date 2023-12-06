#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_dust() {
  _nredf_get_sys_info

  local GHUSER="bootandy"
  local GHREPO="dust"
  local BINARY="dust"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${GHREPO}-${TAGVERSION}-${NREDF_UNAMEM}-${NREDF_PLATFORM}.tar.gz"
  local VERSION_CMD="--version | awk '/Dust/{print \$2}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    tar -xzf "${NREDF_DOWNLOADS}/${FILENAME}" -C "${NREDF_DOWNLOADS}/"
    cp "${NREDF_DOWNLOADS}/${FILENAME%.tar.gz}/${BINARY}" "${XDG_BIN_HOME}/"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"
}