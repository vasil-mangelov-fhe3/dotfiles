#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh
# shellcheck disable=SC2016,SC2155

function _nredf_tool_nvim() {
  _nredf_get_sys_info

  if [[ ${NREDF_OS} =~ ^(macos|windows)$ ]]; then
    return 0
  fi

  local GHUSER="neovim"
  local GHREPO="neovim"
  local BINARY="nvim"
  local TAGVERSION="$(_nredf_github_latest_release "${GHUSER}" "${GHREPO}" "v")"
  local VERSION="${TAGVERSION#v}"
  local FILENAME="${BINARY}.appimage"
  local VERSION_CMD="--version | awk '/NVIM/{print \$2}'"
  local DOWNLOAD_CMD="_nredf_github_download_latest \"${GHUSER}\" \"${GHREPO}\" \"${FILENAME}\" \"${TAGVERSION}\""
  local EXTRACT_CMD='
    if [[ -f "${NREDF_DOWNLOADS}/${BINARY}.appimage" ]]; then
      chmod +x "${NREDF_DOWNLOADS}/${BINARY}.appimage"
    else
      return 1
    fi
    PRERC_CURRENT_DIR=$(pwd)
    if [[ -d "${HOME}/.cache/vim/" ]]; then
      cd "${HOME}/.cache/vim/" || return
      [[ -d "${HOME}/.cache/vim/squashfs-root" ]] && rm -rf "${HOME}/.cache/vim/squashfs-root"
    else
      mkdir -p "${HOME}/.cache/vim/"
      cd "${HOME}/.cache/vim/" || return
    fi
    "${NREDF_DOWNLOADS}/${BINARY}.appimage" --appimage-extract &>/dev/null
    cd "${PRERC_CURRENT_DIR}" || return
    unset PRERC_CURRENT_DIR
    ln -sf "${HOME}/.cache/vim/squashfs-root/AppRun" "${XDG_BIN_HOME}/nvim"
  '

  _nredf_install_tool "${BINARY}" "${FILENAME}" "${TAGVERSION}" "${VERSION}" "${VERSION_CMD}" "${DOWNLOAD_CMD}" "${EXTRACT_CMD}"
}
