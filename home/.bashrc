# .bashrc
# Project: .prompt
# Description: ...? Its a .bashrc file... http://lmgtfy.com/?q=.bashrc
# Creator: Justin Doyle <justin@jmdoyle.com>
# Date: 2/9/2013

export CLICOLOR=1
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

##########################
# UTILITY FUNCTIONS
##########################
#function echo(){
#    if shopt -q login_shell; then
#       echo "$@"
#    fi
#}

########################################################################################################################
## LIQUIDPROMPT
########################################################################################################################
source ~/.prompt/liquid/liquidprompt

########################################################################################################################
## SHELL AND HISTORY OPTIONS
########################################################################################################################
export HISTCONTROL=ignorespaces
export HISTSIZE=10000
export HISTFILESIZE=10000

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e $(ti_setaf 6))[%d/%m %H:%M:%S]$(echo -e ${ti_sgr0}) "
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts

#Set the TERM variable
# export TERM=xterm-256color

shopt -s histappend
shopt -s checkwinsize

########################################################################################################################
## SET COLOR PROMPT
########################################################################################################################
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

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Use existing $HOME/.bash_aliases if they exist (jdoyle aliases are set elsewhere)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi


########################################################################################################################
## COMPLETION
########################################################################################################################
# Explicitly enable bash completion
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

########################################################################################################################
# SET MOTD
########################################################################################################################
ALERT=${BOLD_WHITE}${On_Red} # Bold WHITE on red background

function motd {
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
        echo "liquidprompt: terminal $TERM not supported" >&2
        ti_setaf () { : ; }
    fi

    MEM_TOTAL=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 2)
    MEM_USED=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 3)
    MEM_FREE=$(free -m | grep Mem | sed -r 's/\s+/ /g' |  cut -d " " -f 4)

    DISK=$(df -h | ack '^/dev\S+\s+(\d+G)\s+(\d+G)\s+(\d+G)\s+(\d+%).*/$' --output '$1 $2 $3 $4')
    DISK_TOTAL=$(echo $DISK | cut -d " " -f 1)
    DISK_USED=$(echo $DISK | cut -d " " -f 2)
    DISK_FREE=$(echo $DISK | cut -d " " -f 3)
    DISK_PCT=$(echo $DISK | cut -d " " -f 4)

    # MOTD and login message
    echo ""
    echo -e "$(ti_setaf 5)Welcome to ${ti_bold}$(ti_setaf 6)$HOSTNAME$(ti_setaf 5) (${ti_sgr0}$(ti_setaf 6)$HOST_IP$(ti_setaf 5)${ti_bold}), $(ti_setaf 6)$USER$(ti_setaf 5) (${ti_sgr0}$(ti_setaf 6)$CLIENT_IP$(ti_setaf 5)${ti_bold}).${ti_sgr0}"
    echo -en "$(ti_setaf 5)Current server time is $(ti_setaf 3)$(date)$(ti_setaf 5).${ti_sgr0}\n"
    echo -en "$(ti_setaf 6)Mem: $(ti_setaf 3)${MEM_USED}m$(ti_setaf 5)/$(ti_setaf 3)${MEM_TOTAL}m $(ti_setaf 5)Used, $(ti_setaf 3)${MEM_FREE}m$(ti_setaf 5) Free. "
    echo -e "$(ti_setaf 6)Disk: $(ti_setaf 3)${DISK_USED}$(ti_setaf 5)/$(ti_setaf 3)${DISK_TOTAL} $(ti_setaf 5)($(ti_setaf 3)${DISK_PCT}$(ti_setaf 5)) Used, $(ti_setaf 3)${DISK_FREE}$(ti_setaf 5) Free."

    function _exit()              # Function to run upon exit of shell.
    {
        echo -e "${ti_bold}$(ti_setaf 1)I'll miss you!${ti_sgr0}"
    }
    trap _exit EXIT
}

motd

########################################################################################################################
# ERROR HANDLING
########################################################################################################################
command_not_found_handle () {
  echo -e "\e[1;31mI'm sorry, Dave. I'm afraid I can't do that.\n$0: $1: command not found\e[0;0m";
  return 127; #return bash's error code for command not found
}

########################################################################################################################
# PATH MODIFICATIONS
########################################################################################################################
# Use pathadd to avoid duplicate entries in $PATH
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

# Add personal script bins to PATH
pathadd $HOME/.prompt/bin

# git-extra-commands
pathadd $HOME/.prompt/thirdparty-scripts/git-extra-commands/bin

# Add cwd to path (NOTE: This is potentially dangerous and exploitable. DON'T FUCK IT UP.)
pathadd .

########################################################################################################################
# ALIASES AND FUNCTIONS
########################################################################################################################
# Source other bash files
source $HOME/.prompt/etc/.bashrc_functions
source $HOME/.prompt/etc/.bashrc_aliases
source $HOME/.prompt/etc/npm_completion

# Enable syntax highlight for /usr/bin/less
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

# Git aliases (aka; A message from the Council for the Preservation of Keyboards)
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

########################################################################################################################
# INIT STATEMENTS
########################################################################################################################
trap on_bash_exit EXIT

# Automatically set DISPLAY and SSH into Virtualbox dev machine if we're in cygwin
if [[ "$(uname | grep CYGWIN)" != "" ]]; then
    export DISPLAY=:0.0
    ssh jdoyle@192.168.56.140
fi
