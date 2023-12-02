#!/usr/bin/env bash
#
# vim: ts=2 sw=2 et ff=unix ft=bash syntax=sh

function _nredf_cleanup_dotfiles() {
  if _nredf_last_run; then
    return 0
  fi

  if [[ "${NREDF_OS}" == "linux" ]]; then
    echo -e '\033[1mSearch and delete broken symlinks\033[0m'
    find "${HOME}" -type l ! -exec test -e {} \; -delete
    _nredf_last_run "" "true"
  fi
}
