# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Additional config
source ${HOME}/.config/zsh/homesickrc

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="bullet-train"

# Use hyphen-insensitive completion. Case sensitive completion must
# be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Change the command execution time stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=${HOME}/.config/zsh

# Set a different zgen path
ZGEN_DIR=${HOME}/.config/zgen

# You may need to manually set your language environment
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# load zgen
source "${HOME}/.config/zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
	# specify plugins here
	zgen oh-my-zsh
	zgen oh-my-zsh
	zgen oh-my-zsh plugins/git
	zgen oh-my-zsh plugins/colored-man-pages
	zgen oh-my-zsh plugins/colorize
	zgen oh-my-zsh plugins/cp
	zgen oh-my-zsh plugins/gpg-agent
	zgen oh-my-zsh plugins/npm
	zgen oh-my-zsh plugins/rvm
	zgen oh-my-zsh plugins/pyenv
	zgen oh-my-zsh plugins/virtualenv
	zgen load zsh-users/zsh-syntax-highlighting
	zgen load chrissicool/zsh-256color
	zegn load zsh-users/zsh-completions
	# generate the init script from plugins above
	zgen save
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
