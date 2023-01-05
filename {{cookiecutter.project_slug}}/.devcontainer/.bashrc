# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1): increased manually
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

if [[ $machine != Windows ]]; then
  shopt -s direxpand
fi

# Save history after each command, not only when session terminate
PROMPT_COMMAND='history -a'

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# FORCED to yes manually
force_color_prompt=yes

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# ************************************************
#             C U S T O M    S T U F F
# ************************************************

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Darwin;;
    CYGWIN*|MINGW*|MSYS*)    machine=Windows;;
    *)          machine="UNKNOWN:${unameOut}"
esac

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ -d "$HOME/.cargo/bin" ]; then
  export PATH=$HOME/.cargo/bin:$PATH
fi

eval "$(thefuck --alias)"

# Always export compile_commands.json
export CMAKE_EXPORT_COMPILE_COMMANDS=ON

# Change default Ninja-build status
export NINJA_STATUS="[%p][%f/%t] "

# Get Ctest to use google test colors
export GTEST_COLOR=1

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Setting fd as the default source for fzf
# export FZF_DEFAULT_COMMAND=fd --type f
# Follow symlinks, do not exclude hidden files
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"

# Make vim the default editor
export VISUAL=gvim
export EDITOR=vim

# ************************************************
#       Modify the default terminal prompt
# ************************************************

# Default: PS1='\h:\W \u\$ '
# PS1 The value of this parameter is expanded (see PROMPTING below) and used as the primary prompt string.
# =   equals
# '   single quote
# \h  the hostname up to the first ‘.’
# :   colon
# \W  the basename of the current working directory, with $HOME abbreviated with a tilde
# \w is just the current directory (not the full path)
#     white space
# \u  the username of the currentconfig state user
# \$  if the effective UID is 0, a #, otherwise a $
#     white space
# '   single quote
#PS1='\W \u\$'

# Note: all of the following must be done before the first venv is loaded
# (in .bashrc in my case, so load .bashrc at the end)

# http://stackoverflow.com/questions/10406926/how-to-change-default-virtualenvwrapper-prompt
function virtualenv_info(){
    # Get Virtual Env
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv="${VIRTUAL_ENV##*/}"
    else
        # In case you don't have one activated
        venv=''
    fi
    [[ -n "$venv" ]] && echo "($venv)"
}

# disable the default virtualenv prompt change
export VIRTUAL_ENV_DISABLE_PROMPT=1

VENV="\$(virtualenv_info)";

# Red: 0;31m
# Blue: 0;34m
# Green: 0;32m
# Gray: 0;37

# flashy red: 38;5;9m

#COLOR_0="38;5;143m" # very light green-brownish
#COLOR_0="0:37m" # Light Gray
#COLOR_1="38;5;167m" # Some light red
#COLOR_2='38;5;33m' # Some light blue
#PS1="\[\033[$COLOR_0\]${VENV}\[\033[$COLOR_1\]\u\[\033[0m\]@\[\033[$COLOR_2\]\W\[\033[0m\]"

# Text reset color
Color_Off='\[\033[0m\]'

White='\[\033[0:37m\]'
Purple='\[\033[0;35m\]'
Cyan='\[\033[0;36m\]'
Green='\[\033[0;32m\]'

LightGrey='\[\033[0;37m\]'
LightRed='\[\033[38;5;167m\]'
LightBlue='\[\033[38;5;33m\]'
LightGreen='\[\033[38;5;143m\]'

function __ps1_no_git() {
  # (py39)
  PS1="${LightGrey}${VENV}${Color_Off}"
  # julien
  PS1="$PS1""${LightGreen}\u${Color_Off}"
  # Sep
  PS1="$PS1""@"
  # Workdir, without full path
  PS1="$PS1""${LightBlue}\W${Color_Off}"
}

function __ps1_end() {
    # Finish with the $ sign an a space
  PS1="$PS1""${LightGrey}""$""${Color_Off} "
}

function set_ps1_no_git(){
  __ps1_no_git
  __ps1_end
  }

function set_ps1_with_git(){
  __ps1_no_git
  if test -f ~/.config/git/git-prompt.sh; then
    source ~/.config/git/git-prompt.sh
    # Git specific
    # unstage = (*) and staged (+) changes
    export GIT_PS1_SHOWDIRTYSTATE=1
    # add '$' if something is stashed
    #export GIT_PS1_SHOWSTASHSTATE=1
    # add '%' if untracked files
    export GIT_PS1_SHOWUNTRACKEDFILES=1
    # add "<" if you're behind the remote tracked branch, ">" if ahead
    export GIT_PS1_SHOWUPSTREAM="auto"
    # Color hints
    export GIT_PS1_SHOWCOLORHINTS=1
    # Don't add a space between the remote name and indications
    export GIT_PS1_STATESEPARATOR=" "

    # Add branch name
    PS1="$PS1""${LightGreen}\$(__git_ps1)${Color_Off}"
  fi
  # Finish
  __ps1_end
}

# Default prompt with git
set_ps1_with_git
