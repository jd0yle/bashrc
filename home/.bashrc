# .prompt
# Project: .prompt
# Description: A collection of bashrc settings, utility functions/scripts, and QOL enhancements via .bashrc
# Creator: Justin Doyle <justin@jmdoyle.com>
# Date: 2/9/2013
# USAGE:
#    1) Move the 'prompt' directory (the root dir of this project) to $HOME/.prompt
#    2) From your $HOME directory, run '> .prompt/install.sh'
#    3) Restart your shell sessions, or do '> source ~.bashrc'

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

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend                       # append history file
#export PROMPT_COMMAND="history -a"        # update histfile after every command

# After each command, append to the history file and reread it
#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a"

export HISTCONTROL=ignoredups:erasedups:ignorespaces
export HISTSIZE=10000
export HISTFILESIZE=10000

export TIMEFORMAT=$'\nreal %3R\tuser %3U\tsys %3S\tpcpu %P\n'
export HISTIGNORE="&:bg:fg:ll:h"
export HISTTIMEFORMAT="$(echo -e $(ti_setaf 6))[%d/%m %H:%M:%S]$(echo -e ${ti_sgr0}) "
export HOSTFILE=$HOME/.hosts    # Put a list of remote hosts in ~/.hosts

#Set the TERM variable
# export TERM=xterm-256color

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
# Set global color variables
export COLOR_RESET="\e[0m"
export COLOR_DEFAULT="\e[39m"

export COLOR_BOLD="\e[1m"
export COLOR_DIM="\e[2m"
export COLOR_UNDERLINE="\e[4m"

export COLOR_BLACK="\e[30m"
export COLOR_RED="\e[31m"
export COLOR_GREEN="\e[32m"
export COLOR_YELLOW="\e[33m"
export COLOR_BLUE="\e[34m"
export COLOR_MAGENTA="\e[35m"
export COLOR_CYAN="\e[36m"
export COLOR_LIGHTGRAY="\e[37m"
export COLOR_WHITE="\e[97m"

export COLOR_BGDEFAULT="\e[49m"
export COLOR_BGBLACK="\e[40m"
export COLOR_BGRED="\e[41m"
export COLOR_BGGREEN="\e[42m"
export COLOR_BGYELLOW="\e[43m"
export COLOR_BGBLUE="\e[44m"
export COLOR_BGMAGENTA="\e[45m"
export COLOR_BGCYAN="\e[46m"
export COLOR_BGLIGHTGRAY="\e[47m"
export COLOR_BGWHITE="\e[107m"

########################################################################################################################
# SOURCE EXTRA BASH FILES
########################################################################################################################
source $HOME/.prompt/etc/.bashrc_functions
source $HOME/.prompt/etc/.bashrc_aliases
source $HOME/.prompt/etc/npm_completion

# Enable syntax highlight for /usr/bin/less
#export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
#export LESS=' -R '

# NPM GLOBAL INSTALL LOCATION
NPM_CONFIG_PREFIX=~/.npm-global
NPM_PACKAGES="${HOME}/.npm-packages"
pathadd ~/.npm-global/bin
NODE_PATH="$NPM_PACKAGES/lib/node_modules:$NODE_PATH"

# PYTHON
pathadd $HOME/.pyenv/bin

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi



# AWS CLI BIN
pathadd ~/.local/bin

########################################################################################################################
# GIT CONFIG, ALIASES, AND COMPLETION
########################################################################################################################
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
function on_bash_exit(){
    echo -e "${COLOR_BOLD}${COLOR_RED}Always have an escape plan.${COLOR_RESET}"
}

trap on_bash_exit EXIT

# Automatically set DISPLAY and SSH into Virtualbox dev machine if we're in cygwin
if [[ "$(uname | grep CYGWIN)" != "" ]]; then
    export DISPLAY=:0.0
    ssh jdoyle@192.168.56.140
fi

PATH="/home/jdoyle/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/jdoyle/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/jdoyle/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/jdoyle/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/jdoyle/perl5"; export PERL_MM_OPT;
