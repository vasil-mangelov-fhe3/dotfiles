#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_calico() {
  _nredf_get_sys_info

  local GHUSER="projectcalico"
  local GHREPO="calico"
  local BINARY="calicoctl"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}-${NREDF_UNAME_LOWER}-${NREDF_ARCH}"
  local VERSION_CMD="version | awk '/Client Version/{print \$3}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    cp -f "${NREDF_DOWNLOADS}/${FILENAME}" "${XDG_BIN_HOME}/${BINARY}"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"
}
