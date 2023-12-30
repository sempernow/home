# source /etc/profile.d/edn.sh
#####################################
# Configure bash shell @ EDN subnet
#####################################
[[ "$isBashEDNSourced" ]] && return
isBashEDNSourced=1

set -a # Export all

[[ $(type -t docker) ]] && {
    
    alias registry='echo "docker-ng-untrusted-group.northgrum.com"'
}

[[ $(type -t minikube) ]] && {

    # Minikube will not run on NFS, and requires ftype=1 if an XFS volume.
    export MINIKUBE_HOME=/opt/k8s/minikube
    export CHANGE_MINIKUBE_NONE_USER=true # Does nothing
    [[ -d $MINIKUBE_HOME ]] || {
        echo '=== MINIKUBE_HOME: path NOT EXIST.'
    }

    # Set proxy environment (make idempotent)
    #mini_netwk_addr=$(minikube node list |awk '{print $2}' |awk '{split($1,p,"."); $1=p[1]"."p[2]"."p[3]} 1')
    no_proxy_minikube="10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24"

    # Configure all the HTTP(S) proxy environment vars (once) 
    [[ $(echo "$NO_PROXY" |grep $no_proxy_minikube) ]] || {

        HTTP_PROXY="$http_proxy"
        HTTPS_PROXY="$https_proxy"

        no_proxy_core_static="localhost,127.0.0.1,192.168.0.0/16,172.16.0.0/16,.entds.ngisn.com,.edn.entds.ngisn.com,.dilmgmt.c4isrt.com,.dil.es.northgrum.com,.ms.northgrum.com,.es.northgrum.com,.northgrum.com"
        [[ $no_proxy ]] || no_proxy="$no_proxy_core_static"
        no_proxy_core="${no_proxy}"
        no_proxy_minikube="10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24"

        NO_PROXY="$no_proxy_core,$no_proxy_minikube"
        no_proxy="$NO_PROXY"
    }

    #echo "=== TEST : USER : '$USER'"

    # mperms : Reset all config.json file permissions 
    # that are recurringly misconfigured per `minikube start`.
    mperms(){ 
        [[ -d $MINIKUBE_HOME ]] && {
            find $MINIKUBE_HOME -type f -name 'config.json' \
                -exec sudo chmod 0664 {} \; 
        }
    }

    # Restart minikube if not running, and 
    # reset permissions on all /config.json if user is its owner.
    [[ $(minikube status -o json 2>/dev/null |jq -Mr .Host) != 'Running' ]] && {
        minikube start && [[ $USER == '4n52626' ]] && mperms
    }

}

set +a # End export all

## End here if not interactive
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"
