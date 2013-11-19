################################################
#
#
#	For Entries that you want only local or
#	per user use ~/.bashrc_local
#
#
################################################

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#check if ghar is installed
if [ -d $HOME/.ghar ]; then
	export PATH=$PATH:$HOME/.ghar/bin/
	. $HOME/.ghar/ghar-bash-completion.sh
else
	echo "Please install ghar for full functionality (https://github.com/philips/ghar.git)"
fi

if [ -f $HOME/.profile.d/exports ]; then
	. .profile.d/exports
fi
if [ -f $HOME/.profile.d/prompt ]; then
	. .profile.d/prompt
fi
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
	. /etc/bash_completion
fi
if [ -f $HOME/.profile.d/completion ]; then
	. .profile.d/completion
fi
if [ -f $HOME/.profile.d/helper_functions ]; then
	. .profile.d/helper_functions
fi
if [ -f $HOME/.bash_aliases ]; then
	. $HOME/.bash_aliases
fi

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# For local definitions.
if [ -f ~/.bashrc_local ]; then
	. ~/.bashrc_local
fi
if [ -f $HOME/.profile.d/startup ]; then
	. .profile.d/startup
fi
