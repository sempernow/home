# source /etc/profile.d/edn.sh
#####################################
# Configure bash shell @ EDN subnet
#####################################
[[ "$isBashEDNSourced" ]] && return
isBashEDNSourced=1

set -a # Export all

[[ $(type -t minikube) ]] && {

    # Minikube will not run on NFS, and requires ftype=1 if an XFS volume.
    export MINIKUBE_HOME=/opt/k8s/minikube
    export CHANGE_MINIKUBE_NONE_USER=true # Does nothing

    # Set proxy environment (make idempotent)
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

    # mperms : Reset all config.json file permissions 
    # that are recurringly misconfigured per `minikube start`.
    mperms(){ 
        [[ -d $MINIKUBE_HOME ]] && {
            find $MINIKUBE_HOME -type f -name 'config.json' \
                -exec sudo chmod 0664 {} \; 
        }
    }

    ## End here if not interactive
    [[ -z "$PS1" ]] && return 0

    # Restart minikube if not running, and 
    # reset permissions on all /config.json if user is its owner.
    [[ $(minikube status -o json 2>/dev/null |jq -Mr .Host) != 'Running' ]] && {
        minikube start && [[ $USER == '4n52626' ]] && mperms
    }
}

set +a # End export all

## End here if not interactive
[[ -z "$PS1" ]] && return 0

set -a # Export all

[[ $(type -t docker) ]] && {
    alias registry='echo "docker-ng-untrusted-group.northgrum.com"'
}

# User shares (NFS/autofs) : Recreate, wake, and set helper functions
cifs_dropbox="/cifs/xfer-wq/DropBox"
cifs_shared="/cifs/xfer-wq/Shared"
[[ -d $cifs_dropbox ]] && { [[ -d $cifs_dropbox/$USER ]] || mkdir -p $cifs_dropbox/$USER; }
[[ -d $cifs_dropbox/$USER ]] && cifs_dropbox="$cifs_dropbox/$USER"
[[ -d $cifs_shared ]] && { [[ -d $cifs_shared/$USER ]] || mkdir -p $cifs_shared/$USER; }
[[ -d $cifs_shared/$USER ]] && cifs_shared="$cifs_shared/$USER"
dropbox(){ push $cifs_dropbox; }
shared(){ push $cifs_shared; }
wake(){ sudo killall -s SIGUSR1 automount && sudo mount -a; }

# @ Reach-in VM
[[ $(hostname |grep ONXWQBL) ]] || {
    printf "\n%s\n" "Hostname(s) of EDN-Provisioned, SSH-configured VM(s)"
    cat ~/.ssh/config |grep Host |grep -v Hostname
}

set +a # End export all

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"
