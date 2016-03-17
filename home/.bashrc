# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

#########################
## SET DEFAULT OPTIONS ##
#########################
export CLICOLOR=1
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi


if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

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
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && consoleLog terminal || consoleLog error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

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


CLIENT_IP=$(consoleLog $SSH_CLIENT | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*')
HOST_IP=$(ifconfig eth1 2>/dev/null | grep -o "inet addr:[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" ||
          ifconfig eth0 2>/dev/null | grep -o "inet addr:[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" ||
          ifconfig en3 2>/dev/null | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")

##########################
# UTILITY FUNCTIONS
##########################
function consoleLog(){
    if shopt -q login_shell; then
       echo "$@"
    fi
}

##########################
# SOURCE LIQUIDPROMP AND SET MOTD
##########################

source ~/.prompt/liquid/liquidprompt

ALERT=${BOLD_WHITE}${On_Red} # Bold WHITE on red background

function motd()
{
    ti_sgr0="$( { tput sgr0 || tput me ; } 2>/dev/null )"
    ti_bold="$( { tput bold || tput md ; } 2>/dev/null )"
    ti_setaf
    if tput setaf >/dev/null 2>&1 ; then
        ti_setaf () { tput setaf "$1" ; }
    elif tput AF >/dev/null 2>&1 ; then
        # *BSD
        ti_setaf () { tput AF "$1" ; }
    elif tput AF 1 >/dev/null 2>&1 ; then
        # OpenBSD
        ti_setaf () { tput AF "$1" ; }
    else
        consoleLog "liquidprompt: terminal $TERM not supported" >&2
        ti_setaf () { : ; }
    fi

    MEM_TOTAL=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 2)
    MEM_USED=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 3)
    MEM_FREE=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 4)

    DISK_TOTAL=$(df -h | head -n 2 | tail -n 1 | sed -r 's/\s+/ /g' | cut -d " " -f 2)
    DISK_USED=$(df -h | head -n 2 | tail -n 1 | sed -r 's/\s+/ /g' | cut -d " " -f 3)
    DISK_FREE=$(df -h | head -n 2 | tail -n 1 | sed -r 's/\s+/ /g' | cut -d " " -f 4)

    # MOTD and login message
    consoleLog -e "$(ti_setaf 5)Welcome to ${ti_bold}$(ti_setaf 6)$HOSTNAME$(ti_setaf 5) (${ti_sgr0}$(ti_setaf 6)$HOST_IP$(ti_setaf 5)${ti_bold}), $(ti_setaf 6)$USER$(ti_setaf 5) (${ti_sgr0}$(ti_setaf 6)$CLIENT_IP$(ti_setaf 5)${ti_bold}).${ti_sgr0}"
    consoleLog -en "$(ti_setaf 5)Current server time is $(ti_setaf 3)$(date)$(ti_setaf 5).${ti_sgr0}\n"
    consoleLog -en "$(ti_setaf 6)Mem: $(ti_setaf 3)${MEM_USED}m$(ti_setaf 5)/$(ti_setaf 3)${MEM_TOTAL}m $(ti_setaf 5)Used, $(ti_setaf 3)${MEM_FREE}m$(ti_setaf 5) Free. "
    consoleLog -e "$(ti_setaf 6)Disk: $(ti_setaf 3)${DISK_USED}$(ti_setaf 5)/$(ti_setaf 3)${DISK_TOTAL} $(ti_setaf 5)Used, $(ti_setaf 3)${DISK_FREE}$(ti_setaf 5) Free."

    function _exit()              # Function to run upon exit of shell.
    {
        consoleLog -e "${ti_bold}$(ti_setaf 1)I'll miss you!${ti_sgr0}"
    }
    trap _exit EXIT
}

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTTIMEFORMAT="$(consoleLog -e $(ti_setaf 6))[%d/%m %H:%M:%S]$(consoleLog -e ${ti_sgr0}) "
export HISTCONTROL=ignoredups
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts
export PATH=/usr/local/bin:/usr/local/sbin:$PATH:/usr/bin/phpstorm/bin

command_not_found_handle () {
  consoleLog -e "\e[1;31mI'm sorry, Dave. I'm afraid I can't do that.\n$0: $1: command not found\e[0;0m";
  return 127; #return bash's error code for command not found
}

motd


###################################################################
################## jdoyle customization ###########################
###################################################################
# Add personal script bins to PATH
export PATH=$PATH:$HOME/.prompt/bin

# Source other bash files
source $HOME/.prompt/etc/.bashrc_functions
source $HOME/.prompt/etc/.bashrc_aliases

########################
# GIT ALIASES
########################
alias g="git"
alias gco="git checkout"
alias gcm="git commit"
alias gbr="git branch"
alias gmg="git merge"
alias gpl="git pull"
alias gps="git push"
alias gcp="git cherry-pick"
alias glg="git log"

# Git branch bash completion
if [ -f  ~/.prompt/bin/git-completion.bash ]; then
  .  ~/.prompt/bin/git-completion.bash

  # Add git completion to aliases
  __git_complete g __git_main
  __git_complete gco _git_checkout
  __git_complete gcm _git_commit
  __git_complete gmg _git_merge
  __git_complete gpl _git_pull
  __git_complete gps _git_push
  __git_complete gbr _git_branch
  __git_complete gcp _git_cherry_pick
  __git_complete glg _git_log
fi

trap on_bash_exit EXIT

# Automatically set DISPLAY and SSH into dev box if we're in cygwin
if [[ "$(uname | grep CYGWIN)" != "" ]]; then
    export DISPLAY=:0.0
    ssh jdoyle@192.168.56.140
fi
