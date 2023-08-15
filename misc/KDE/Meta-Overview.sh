#!/bin/bash -
#===============================================================================
#
#          FILE: Meta-Overview.sh
#
#         USAGE: ./Meta-Overview.sh
#
#   DESCRIPTION: Sets the Meta key to open the overview instead of application
#                launcher
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Steven Kurz (nemesissre@gmail.com),
#  ORGANIZATION: NRE.Com.Net
#       CREATED: 08/15/2023 11:13:37 AM
#      REVISION: 1.0.0
#===============================================================================

set -o nounset                                  # Treat unset variables as an error

kwriteconfig5 --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.kglobalaccel,/component/kwin,,invokeShortcut,Overview"

qdbus org.kde.KWin /KWin reconfigure
