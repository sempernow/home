# source /etc/profile.d/k8s.sh
##################################################
# Configure bash shell for Docker
##################################################
[[ $(type -t docker) ]] || return

set -a # Export all

## docker image
alias di='docker image ls'
alias dit='docker image ls --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}"'
alias dij='docker image ls --digests --format "{{json .}}" |jq -Mr . --slurp'
drmi(){ # Remove image(s) per substring ($1), else prune 
    [[ "$@" ]] && {
        docker image ls |grep "${@%:*}" |grep "${@#*:}" |gawk '{print $3}' |xargs docker image rm -f
    } || {
        docker image prune -f 
    }
}
## docker container 
alias dps='docker container ps --format "table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias dpsa='docker ps -a --format "table {{.ID}}  {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
dstart(){ [[ "$@" ]] && docker container ls -a |grep "$@" |gawk 'NR == 1 {print $1}' |xargs docker container start; }
dstop(){ [[ "$@" ]] && docker container ls    |grep "$@" |gawk '{print $1}' |xargs docker container stop; }  
drm(){ [[ "$@" ]] && docker container ls -a |grep "$@" |gawk '{print $1}' |xargs docker container rm -f; }
## docker network
dnetl(){ docker network ls $@; }
alias dnet=dnetl
dneti(){ docker network inspect $@; }
dnetp(){ docker network prune -f; }
## docker volume
dvl(){ docker volume ls $@; }
dvi(){ docker volume inspect $(docker volume ls -q) |jq -rM '.[] | .Name, .CreatedAt'; }
dvp(){ docker volume prune -f; }
## docker exec
dex(){
    [[ "$1" ]] && {
        docker exec -it $(docker container ls --filter name=$1 -q) ${2:-sh} $3 $4 $5 $6 $7 $8 $9
    }
}
## docker stats
dstats(){ 
    [[ "$1" == '' ]] && _no_stream='--no-stream' || _no_stream=''
    docker stats $_no_stream --format 'table {{.ID}}  {{.Name}}\t{{.CPUPerc}}  {{.MemUsage}}\t{{.MemPerc}}  {{.NetIO}}\t{{.BlockIO}}\t{{.PIDs}}'
}


set +a # End export all

## End here if not interactive
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"
