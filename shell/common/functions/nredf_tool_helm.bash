#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_helm() {
  _nredf_get_sys_info

  local GHUSER="helm"
  local GHREPO="helm"
  local BINARY="helm"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}-${TAGVERSION}-${NREDF_UNAME_LOWER}-${NREDF_ARCH}.tar.gz"
  local VERSION_CMD="version --template\='{{ .Version }}' 2>/dev/null"
  local DOWNLOAD_CMD="command curl -Lfso \"${NREDF_DOWNLOADS}/${FILENAME}\" \"https://get.helm.sh/${FILENAME}\""
  local EXTRACT_CMD='
    tar -xzf "${NREDF_DOWNLOADS}/${FILENAME}" -C "${NREDF_DOWNLOADS}/"
    mv "${NREDF_DOWNLOADS}/${NREDF_UNAME_LOWER}-${NREDF_ARCH}/${BINARY}" "${XDG_BIN_HOME}/${BINARY}"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"

  if [[ "${NREDF_SHELL_NAME}" =~ ^(bash|zsh)$ ]]; then
    [[ -f "${XDG_BIN_HOME}/${BINARY}" ]] && "${XDG_BIN_HOME}/${BINARY}" completion "${NREDF_SHELL_NAME}" 2>/dev/null > "${XDG_CONFIG_HOME}/completion/${NREDF_SHELL_NAME}/_${BINARY}"
  fi
}
