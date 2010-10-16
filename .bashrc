#!/bin/bash

# setup some basic variables
: ${HOME=~}
: ${LOGNAME=$(id -un)}
: ${UNAME=$(uname)}

# ----------------------------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------------------------

# complete hostnames from
: ${HOSTFILE=~/.ssh/known_hosts}

# readline inputrc
: ${INPUTRC=~/.inputrc}


# ----------------------------------------------------------------------
#  SHELL OPTIONS
# ----------------------------------------------------------------------

# bring in system bashrc
test -r /etc/bashrc && . /etc/bashrc

# notify of bg job completion immediately
set -o notify

# fuck that you have new mail shit
unset MAILCHECK

# disable core dumps
ulimit -S -c 0

# default umask
umask 0022

# ----------------------------------------------------------------------
# PATH
# ----------------------------------------------------------------------

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" && PATH="$HOME/bin:$PATH"

# ----------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION
# ----------------------------------------------------------------------

# detect interactive shell
case "$-" in
    *i*) INTERACTIVE=1 ;;
    *)   unset INTERACTIVE ;;
esac

# detect login shell
case "$0" in
    -*) LOGIN=1 ;;
    *)  unset LOGIN ;;
esac

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# always use PASSIVE mode ftp
: ${FTP_PASSIVE:=1}
export FTP_PASSIVE

# ignore backups, CVS directories, python bytecode, vim swap files
FIGNORE="~:CVS:#:.pyc:.swp:.swa:apache-solr-*"
HISTCONTROL=ignoreboth

# ----------------------------------------------------------------------
# PAGER / EDITOR
# ----------------------------------------------------------------------

# EDITOR
EDITOR="mvim"
export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER

# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

source .bashrc.d/git-completion.bash
source .bashrc.d/prompt.bash

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    # put ports on the paths if /opt/local exists
    test -x /opt/local && {
        PORTS=/opt/local

        # setup the PATH and MANPATH
        PATH="$PORTS/bin:$PORTS/sbin:$PATH"
        MANPATH="$PORTS/share/man:$MANPATH"

        # nice little port alias
        alias port="sudo nice -n +18 $PORTS/bin/port"
    }

    test -x /usr/pkg && {
        PATH="/usr/pkg/sbin:/usr/pkg/bin:$PATH"
        MANPATH="/usr/pkg/share/man:$MANPATH"
    }

    # setup java environment. puke.
    JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"
    ANT_HOME="/Developer/Java/Ant"
    export ANT_HOME JAVA_HOME
fi

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
alias du1='du -h --max-depth=1'
alias fn='find . -name'
alias hi='history | tail -20'

#general aliases
alias ..="cd .."
alias la="ls -la"
alias ll="ls -l"
alias l.="ls -d .*"
alias pa="ps ax -r -m -c"
alias p="ps aux | grep"
alias k="kill -9"

# ruby gems
alias gemi='sudo gem install'
alias gemu='sudo gem update'
alias gemun='sudo gem uninstall'

# From http://hayne.net/MacDev/Bash/aliases.bash
set completion-ignore-case On

# dsrm: removes all .DS_Store file from the current dir and below
alias dsrm="find . -type f -name .DS_Store -print0 | xargs -0 rm"

# Git
alias gc="git commit -a -v"
alias gci="git ci"
alias gco="git co"
alias ga="git add"
alias gs="git status -uno" # Display only tracked files
alias gb="git checkout -b"
alias g="git"
alias gl="git log --pretty=oneline"
alias gdi='git diff'
cdgit () { cd "$1" ; git pull origin master ; }

alias macvim='/Applications/MacVim.app/Contents/MacOS/Vim -g'
alias m='/Applications/MacVim.app/Contents/MacOS/Vim -g .'

# JRuby && Rails
JRUBY_DEV='~/dev/jruby'
alias jrs='jruby -S'
alias jrake='jruby -S rake'
alias sc='script/console'
alias ss='script/server'
alias ssd='script/server --debugger'
alias sg='script/generate'
alias jdev="${JRUBY_DEV}/bin/jruby"
alias jirbdev="${JRUBY_DEV}/bin/jruby -S jirb"
alias jirbdev1.9="${JRUBY_DEV}/bin/jruby --1.9 -S jirb"

# MySQL
alias my='mysql -uroot'
alias mya='mysqladmin -uroot'

# ----------------------------------------------------------------------
# RVM
# ----------------------------------------------------------------------

if [[ -s "$HOME/.rvm/scripts/rvm" ]] ; then source "$HOME/.rvm/scripts/rvm" ; fi
alias use="rvm"

# ----------------------------------------------------------------------
# BASH COMPLETION
# ----------------------------------------------------------------------

test -z "$BASH_COMPLETION" && {
    bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}
    test -n "$PS1" && test $bmajor -gt 1 && {
        # search for a bash_completion file to source
        for f in /usr/local/etc/bash_completion \
                 /usr/pkg/etc/bash_completion \
                 /opt/local/etc/bash_completion \
                 /etc/bash_completion
        do
            test -f $f && {
                . $f
                break
            }
        done
    }
    unset bash bmajor bminor
}

# override and disable tilde expansion
_expand() {
    return 0
}

# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hBG"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
alias ls="command ls $LS_COMMON"
