# .bash_profile

# Get the aliases and functions
[[ -f ~/.bashrc ]] && source ~/.bashrc

## End here if not interactive
[[ "$-" != *i* ]] && return
[[ -n "$PS1" ]] || return

[[ $BASH_SOURCE ]] && echo "@ ${BASH_SOURCE##*/}"

# User specific environment and startup programs
