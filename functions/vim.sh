[[ "$isBashVimSourced" ]] && return
#export isBashVimSourced=1

if [ -n "${BASH_VERSION-}" -o -n "${KSH_VERSION-}" -o -n "${ZSH_VERSION-}" ]; then
  [ "`/usr/bin/id -u 2>/dev/null || echo 0`" -le 200 ] && return
  # for bash and zsh, only if no alias is already set
  alias vi >/dev/null 2>&1 || alias vi=vim
fi

## End here if not interactive
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"
