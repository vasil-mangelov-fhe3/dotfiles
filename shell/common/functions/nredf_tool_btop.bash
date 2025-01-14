#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_btop() {
  _nredf_get_sys_info

  local FILENAME_SUFFIX
  case ${NREDF_OS} in
    macos)
      # Not ready yet
      return 0
      # shellcheck disable=SC2317
      FILENAME_SUFFIX=${NREDF_OS_RELEASE:-bigsur}
      ;;
    windows)
      return 0
      ;;
    linux)
      FILENAME_SUFFIX=${NREDF_LIBC}
      ;;
  esac

  local GHUSER="aristocratos"
  local GHREPO="btop"
  local BINARY="btop"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}-${NREDF_UNAMEM}-${NREDF_OS}-${FILENAME_SUFFIX}.tbz"
  local VERSION_CMD="-v | awk '{sub(\",\",\"\"); print \$3}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    tar -xjf "${NREDF_DOWNLOADS}/${FILENAME}" -C "${NREDF_DOWNLOADS}/"
    cp -f "${NREDF_DOWNLOADS}/${BINARY}/bin/${BINARY}" "${XDG_BIN_HOME}/"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"
}
