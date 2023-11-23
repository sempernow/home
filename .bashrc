# .bashrc
# Share scripts @ /usr/local/scripts/

isBash="$(echo $SHELL |grep bash)"
# If syntax not POSIX, abide other, if bash
[[ $isBash ]] && set +o posix 

# Source global definitions
[[ -f /etc/bashrc ]] && source /etc/bashrc 

# User specific environment
[[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]] \
    || PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# History Options
#
# Don't put duplicate lines in the history; ignore is leading space.
export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups,ignoreboth
#
# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well
#
# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# Umask
#
# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# Aliases
#
# Some people use a different file for aliases
[[ -f "${HOME}/.bash_aliases" ]] && source "${HOME}/.bash_aliases"
#
# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.
#
# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'
#
# alias less='less -r'                          # raw control characters
# alias whence='type -a'                        # where, of a sort

# Meta
alias ffmpeg='ffmpeg -hide_banner'
alias goclean='go clean -i -r -cache -testcache -fuzzcache'
alias gpg=GnuPG
alias os='cat /etc/os-release'
alias pip='python3 -m pip'
alias python=python3
alias vi=vim

# FS
alias ls='ls -hl --color=auto --group-directories-first'
alias ll='ls -AhlrtgGL --time-style=long-iso' 
ll >/dev/null 2>&1 || alias ll='ls -AhlrtL --group-directories-first'
alias df='df -hT'
alias du='du -h'
alias lsblk='lsblk -o SIZE,LABEL,NAME,MAJ:MIN,TYPE,FSTYPE,MOUNTPOINT,UUID'
alias tree='tree -I vendor --dirsfirst'
alias copy='cp -up'
alias update='cp -urpv'
alias edit=openedit
alias open=openedit
alias isdos=isDOS

# Text
alias cls=clear
alias grep='grep --color'                     # show differences in colour
alias grepb='grep -B10'
alias grepa='grep -A10'
alias grepba='grep -B5 -A5'
# alias egrep='egrep --color=auto'              # show differences in colour
# alias fgrep='fgrep --color=auto'              # show differences in colour
alias jq='jq -C'
alias sha2=sha256
[[ $(type -t encodeurl) ]] && alias urlencode=encodeurl

# network
alias ip='ip -c'

# ssh
alias fpr='ssh-keygen -E md5 -lvf'
alias fprs='ssh-keygen -lvf'

# Functions
[[ -f "${HOME}/.bash_functions" ]] && source "${HOME}/.bash_functions"

# @ Windows
[[ -f "${HOME}/.bash_win" ]] && source "${HOME}/.bash_win"

## End here if not interactive
[[ "$-" != *i* ]] && return
[[ -n "$PS1" ]] || return

## Source all completions that abide compspec : See man bash "Programmable Completion" section
_completion_loader(){
    source "/etc/bash_completion.d/$1.sh" >/dev/null 2>&1 && return 124
}
[[ $(type -t complete) ]] \
    && complete -D -F _completion_loader -o bashdefault -o default

git_prompt=/usr/share/git-core/contrib/completion/git-prompt.sh
[[ -f $git_prompt ]] && source $git_prompt # function: __git_ps1 

NC='\e[0m'
BLUE='\e[1;34m'
GREEN='\e[1;32m'
WHITE='\e[0;37m'
GREY='\e[1;30m'
YELLOW='\e[1;33m'

# Prompt
export TZ='America/New_York'
#os="$(os |grep NAME |head -n1 |cut -d'=' -f2 |sed 's/"//g')"
#ver="$(os |grep VERSION_ID |head -n1 |cut -d'=' -f2 |sed 's/"//g')"
[[ $isBash ]] && prompt=$'\u2629' || prompt='$'                 # Set prompt : Multi-byte Unicode char if UTF-8, else "$"
[[ $(id -u) == '0' ]] && prompt='#'                             # Reset prompt if user is root 
PS1='\[\e]0;\u@\h\007\]'                                        # Window title
PS1="$PS1"'\n'                                                  # newline

PS1="$BLUE\u$GREY@$BLUE\h"                                      # $USER@$(hostname)
[[ $( type -t __git_ps1 ) ]] && PS1="$PS1""$WHITE`__git_ps1`"   # + Show "(BRANCH)"            (@ ./.git)
#PS1="$PS1""$GREY [$os$ver] [\t] [$SHLVL] [#\j]$NC"             # + [$os$ver] [HH:mm:ss] [$SHLVL] [jobs]
[[ $isBash ]] && PS1="$PS1""$GREY [\t] [$SHLVL] [#\j]$NC"       # + [HH:mm:ss] [$SHLVL] [jobs] (@ bash)
[[ ! $isBash ]] && PS1="$PS1""$GREY [\t] [$SHLVL] $NC"          # + [HH:mm:ss] [$SHLVL]        (@ sh)
PS1="$PS1""$GREEN \w$NC"                                        # + /full/path/of/pwd
PS1="$PS1"'\n'"$GREEN$prompt $NC"                               # + newline + prompt + whitespace

[[ $BASH_SOURCE ]] && echo "@ ${BASH_SOURCE##*/}"
