# source /etc/profile.d/k8s.sh
##################################################
# Configure bash shell for kubectl|minikube|helm
##################################################
[[ "$isBashK8sSourced" ]] && return
isBashK8sSourced=1

set -a # Export all

[[ $(type -t kubectl ) ]] && {

    all='deploy,sts,rs,pod,ep,svc,ingress,cm,secret,pvc,pv'

    # kubectl completion
    set +o posix # Abide non-POSIX syntax 
    source <(kubectl completion bash)

    # k + completion
    alias k=kubectl
    complete -o default -F __start_kubectl k

    # Get/Set kubectl namespace : Usage: kn [NAMESPACE]
    kn() { 
        [[ "$1" ]] && {
            kubectl config set-context --current --namespace $1
        } || {
            kubectl config view --minify |grep namespace |cut -d" " -f6
        }
    }
    
    # Get/Set kubectl context : Usage: kx [CONTEXT_NAME]
    kx() { 
        [[ "$1" ]] && {
            kubectl config use-context $1
        } || {
            #kubectl config current-context
            kubectl config get-contexts
        }
    }

    # Get/Set cluster's default StorageClass 
    # (minikube reverts to "standard" per `minikube start`)
    ksc(){
        [[ $1 ]] && {
            default=$(kubectl get sc |grep default |awk '{print $1}')
            [[ $default ]] && { 
                ## If current default exists, then unset it
                kubectl patch sc $default -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
            }
            ## Set default to $1
            kubectl patch sc $1 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
        }
        kubectl get sc
    }

    psk(){ 
        # ps aux, filtering through only k8s-related processes. 
        # ARGs: [k8s-command-name(default: all)]
        k8s='
            containerd
            dockerd
            etcd
            kubelet 
            kube-apiserver
            kube-controller-manager
            kube-scheduler
            kube-proxy
        '
        _ps(){
            [[ "$1" ]] || exit 1
            echo @ $1 
            ps aux |grep -- $1 |tr ' ' '\n' \
                |grep -- -- |grep -v color |grep -v grep
        }
        export -f _ps
        [[ "$1" ]] && _ps $1 || {
            echo $k8s |xargs -n 1 /bin/bash -c '_ps "$@"' _
        }
    }
}

[[ $(type -t minikube) ]] && {

    source <(minikube completion bash)
    
    # d2m : Configure host's Docker client (docker) to Minikube's Docker server.
    d2m(){ [[ $(echo $DOCKER_HOST) ]] || eval $(minikube -p minikube docker-env); }

    mdns() { 
        # TODO : Find a better method (Perhaps resolve @ /etc/hosts)
        # If Minikube's ingress-dns addon is enabled, 
        # then add Minikube's IP as a nameserver for this machine's DNS resolver (idempotently).
        # See manual page /etc/resolv.conf(5)
        [[ $(cat /etc/resolv.conf |grep $(minikube ip)) ]] || {
            [[ $(minikube addons list |grep ingress-dns) && $(minikube ip |grep 192.168) ]] && {
                printf "%s\n%s\n" "nameserver $(minikube ip)" "options rotate" \
                    |sudo tee -a /etc/resolv.conf
            }
        }
    }
}

# Helm : Save (.tar) all Docker-image dependencies of a chart 
# using three helper functions: hdi (list), hvi (validate), dis (save).
[[ $(type -t helm) && $(type -t docker) ]] && {
    # List all Docker images of an extracted Helm chart $1 (directory).
    hdi(){
        [[ -d $1 ]] && {
            helm template "$@" \
                |grep image: \
                |sed '/^#/d' \
                |awk '{print $2}' \
                |awk -F '@' '{print $1}' \
                |tr -d '"' \
                |sort -u |tee ${FUNCNAME}@${1##*/}.log
        } || {
            echo "=== USAGE : $FUNCNAME [Any and all options required by helm install] PATH_TO_CHART_FOLDER"
        }
    }

    # Validate all Docker images listed in file $1 against those in Docker's cache
    hvi(){
        [[ -f $1 ]] && {
            [[ -n $(echo $DOCKER_HOST) ]] || eval $(minikube -p minikube docker-env)
            while read -r
            do docker image ls --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" |grep ${REPLY##*/}
            done < $1 |tee ${FUNCNAME}@${1##*/}
        } || {
            echo "=== USAGE : $FUNCNAME PATH_TO_IMAGES_LIST_FILE (E.g., hdi@CHART-VER.log)"
        }
    }

    # Perform `docker save` (to *.tar) on all images listed in file $1.
    # (To load these *.tar, use `docker load` *NOT* `docker import`.)
    dis(){
        [[ -f $1 ]] && {
        while read -r
        do 
            img="$(echo $REPLY |awk '{print $1}')"
            out="$(echo $img |sed 's#/#.#g' |sed 's/:/_/').tar"
            docker image save ${img} -o $out
            printf "%s\t%s\n" $img $out |tee -a ${FUNCNAME}@${1##*/}
        done < $1
        } || {
            echo "=== USAGE : $FUNCNAME PATH_TO_IMAGES_LIST_FILE (E.g., hvi@hdi@CHART-VER.log)"
        }
    }
}

set +a # End export all

## End here if not interactive
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"
