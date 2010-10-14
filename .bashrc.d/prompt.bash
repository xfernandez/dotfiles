#!/bin/bash
#
# Nick Sieger's Bash Prompt

short_pwd ()
{
    local pwd_length=${PROMPT_LEN-40}
    local cur_pwd=$(echo $(pwd) | sed -e "s,^$HOME,~,")
    if [ $(echo -n $cur_pwd | wc -c | tr -d " ") -gt $pwd_length ]; then
	echo "...$(echo $cur_pwd | sed -e "s/.*\(.\{$pwd_length\}\)/\1/")"
    else
	echo $cur_pwd
    fi
}

export TITLE_BASE='${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/~}'
export TITLE="Bash $BASH_VERSION"

title()
{
    local t="$*"
    if [ "$t" ]; then
	TITLE="$t"
    fi
    t="$TITLE  --  [$(eval echo $TITLE_BASE)]"

    case $TERM in
	xterm*)
            echo -ne "\033]0;$t\007"
            ;;
	screen)
            echo -ne "\033_$t\033\\"
            ;;
	*)
            if [ "$TERM_PROGRAM" = iTerm.app ]; then
		osascript <<EOF
tell application "iTerm"
    tell the current terminal
        tell the current session
            set name to "$t"
        end tell
    end tell
end tell
EOF
            fi
    esac
}

# this prints the value of any non-zero exit status after each
# command.
_prompt_command ()
{
    laststatus=$?

    # Disable PROMPT_COMMAND if PATH becomes empty, to avoid errors
    if [ "$PATH" = "" ]; then
        PROMPT_COMMAND=
    else
        if [ $laststatus != 0 ]; then
            echo [exited with $laststatus]
        fi

        git=
        if type git >/dev/null; then
            git=$(__git_ps1)
        fi
	rvm=
	if [ -f ~/.rvm/bin/rvm-prompt ]; then
	    rvm=$(~/.rvm/bin/rvm-prompt i v p g)
	    if [ "$rvm" -a "$rvm" != system ]; then
		rvm=" {$rvm}"
	    else
		rvm=
	    fi
	fi
        # Set the shortPWD environment var so we can use it in our prompt
        # `pwd_length' controls the maximum length of $PWD
        shortPWD=$(short_pwd)$git$rvm
    fi

    title
}

prompt()
{
    local cyan='\[\033[1;36m\]'
    local white='\[\033[0;1m\]'
    local nocolor='\[\033[0m\]'

    if ! perl -e "'$TERM' =~ /(cygwin|ansi|linux|xterm|rxvt)/ or exit 1"; then
        cyan=""
        white=""
        nocolor=""
    fi

    if [ "$SSH_TTY" -o "$USER" = root ]; then
        # Root or remote system, display host and full path
        PS1="$cyan[$white\t$cyan][$white\u@\h:\${shortPWD}$cyan]$nocolor\n$cyan$nocolor"'\$ '
    else
       # Skip user@host when on local system; it will be in the title bar
        PS1="$cyan[$white\t$cyan][$white\${shortPWD}$cyan]$nocolor\n$cyan$nocolor"'\$ '
    fi
}

_growl_prompt_command()
{
    eval $PREV_PROMPT_COMMAND
    growlnotify -n Shell -m "$PROMPT_MEMO exited with $laststatus" Shell
    PROMPT_COMMAND=$PREV_PROMPT_COMMAND
    PREV_PROMPT_COMMAND=
    PROMPT_MEMO=
}

growldone()
{
    PREV_PROMPT_COMMAND=$PROMPT_COMMAND
    PROMPT_COMMAND=_growl_prompt_command
    if [ $# -gt 0 ]; then
	PROMPT_MEMO=$@
    else
	PROMPT_MEMO=Command
    fi
}

# Set up $PS1 and $PROMPT_COMMAND
prompt
export PROMPT_COMMAND=_prompt_command
