#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_btop() {
  _nredf_get_sys_info

  if [[ ${NREDF_OS} =~ ^(macos|windows)$ ]]; then
    return 0
  fi

  local GHUSER="aristocratos"
  local GHREPO="btop"
  local BINARY="btop"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}-${NREDF_UNAMEM}-${NREDF_OS}${NDRDF_LIBC/#/_}.tbz"
  local VERSION_CMD="-v | awk '{sub(\",\",\"\"); print \$3}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    tar -xjf "${NREDF_DOWNLOADS}/${FILENAME}" -C "${XDG_BIN_HOME}" --strip-components=3 --wildcards --no-anchored "bin/${BINARY}"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"
}
