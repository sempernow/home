# source .bash_functions || source /etc/profile.d/${USER}-02-bash_functions.sh

#[[ "$isBashFunctionsSourced" ]] && return
#isBashFunctionsSourced=1

# End here if functions already exist (run once)
#[[ "$(type -t now)" ]] && return

set -a  # EXPORT ALL ...

[[ "$_PID_1xSHELL" ]] || _PID_1xSHELL=$( ps |grep 'bash' |sort -k 7 |awk '{print $1;}' |head -n 1 )

######
# Date

today(){
    # YYY-MM-DD
    t="$(date +%F)";echo "$t"
    #[[ ! "$1" ]] && { REQUIREs putclip ; putclip "$t"; }
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
now(){
    # HH.mm.ss
    t="$(date +%H.%M.%S)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
todaynow(){
    # YYY-MM-DD_HH.mm.ss
    t="$(date +%F_%H.%M.%S)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
utc(){
    # YYY-MM-DDTHH.mm.ss
    t="$(date '+%Y-%m-%dT%H:%M:%S')";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
utco(){
    # YYY-MM-DDTHH.mm.ss-HHHH.TZ  : I.e., this zone's Offset (-HHHH) and its name (TZ)
    t="$(date '+%Y-%m-%dT%H:%M:%S%z.%Z')";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
gmt(){
    # YYY-MM-DDTHH.mm.ssZ  : Appends "Z" for Zero offset AKA "Zulu time" by US military's phonetic alpahabet
    t="$(date -u '+%Y-%m-%dT%H:%M:%SZ')";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
alias zulu=gmt
alias utcz=gmt
iso(){
    # YYY-MM-DDTHH.mm.ss+/-HH:mm
    t="$(date --iso-8601=seconds)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}
isoz(){
    # YYY-MM-DDTHH.mm.ss+00:00
    t="$(date -u --iso-8601=seconds)";echo "$t"
    #[[ ! "$1" ]] && { [[ $(type -t putclip) ]] && putclip "$t"; }
}

####
# FS

ug(){ printf "$(id -u):$(id -g)"; }
path() {
    # Parse and print $PATH
    clear ; echo ; echo '  $PATH (parsed)'; echo
    declare IFS=: ; printf '  %s\n' $PATH
}
[[ $(type -t pushd) ]] && {
    push() {
        # ARGs: DIR-(REL)PATH || DRIVE-LETTER
        [[ "$@" ]] || { echo " NO push (no param)"; return 99; }
        [[ -d "$*" ]] && { pushd "$*" > /dev/null 2>&1 ; return; } || {
            (( ${#1} == 1 )) && { push "$1"; return; }
        }
        echo "=== DIR '$*' NOT EXIST"
    }
    pop() { popd > /dev/null 2>&1 ; }
    up(){ push "$(cd ..;pwd)" ; }
    root(){ push / ; }
    home(){ push "$HOME"; }
    temp(){ push "$TMPDIR"; }
}
mode(){
    # octal human fname
    # ARGs: [path(Default:.)]
    [[ -f "$@" ]] && {
        find "${@%/*}" -maxdepth 1 -type f -iname "${@##*/}" -execdir stat --format=" %04a  %A  %n" {} \+ |sed 's/\.\///'
        return 0
    }
    [[ -d "$@" ]] && d="$@" || d='.'
    find "$d" -maxdepth 1 -type d -execdir stat --format=" %04a  %A  %n" {} \+ |sed 's/\.\///'
    echo ''
    find "$d" -maxdepth 1 -type f -execdir stat --format=" %04a  %A  %n" {} \+ |sed 's/\.\///'
}
alias perms=mode
owner(){
    # owner[uid] group[gid] perms[octal] fname
    # ARGs: [path(Default:.)]
    [[ -f "$@" ]] && {
        find "${@%/*}" -maxdepth 1 -type f -iname "${@##*/}" -execdir stat --format=" %U[%u]  %G[%g]  %A[%04a]  %n" {} \+ |sed 's/\.\///' |sed 's/Administrators/Admns/'
        return 0
    }
    [[ -d "$@" ]] && d="$@" || d='.'
    find "$d" -maxdepth 1 -type d -execdir stat --format=" %U[%u]  %G[%g]  %A[%04a]  %n" {} \+ |sed 's/\.\///' |sed 's/Administrators/Admns/'
    echo ''
    find "$d" -maxdepth 1 -type f -execdir stat --format=" %U[%u]  %G[%g]  %A[%04a]  %n" {} \+ |sed 's/\.\///' |sed 's/Administrators/Admns/'
}
selinux(){
    # SELinux security context : See: man stat (%C)
    # ARGs: [path(Default:.)]
    [[ $(type -t getenforce) ]] || {
        echo "  REQUIREs: SELinux"
        return 0
    }
    [[ -f "$@" ]] && {
        find "${@%/*}" -maxdepth 1 -type f -iname "${@##*/}" -execdir stat --format=" %04a  %A  %C  %n" {} \+ |sed 's/\.\///'
        return 0
    }
    [[ -d "$@" ]] && d="$@" || d='.'
    find "$d" -maxdepth 1 -type d -execdir stat --format=" %04a  %A  %C  %n" {} \+ |sed 's/\.\///'
    echo ''
    find "$d" -maxdepth 1 -type f -execdir stat --format=" %04a  %A  %C  %n" {} \+ |sed 's/\.\///'
}

#########
# systemd
units(){ systemctl list-unit-files; }
journal(){ # -e : Jump to end, --no-pager : Show full message (else each is truncated).
    [[ $2 ]] && { sudo journalctl --no-pager -e $@; return 0; }
    [[ $1 ]] && sudo journalctl --no-pager -e -u $@
    [[ $1 ]] || sudo journalctl --no-pager -xe
}

#######
# Utils

grepall(){ [[ "$@" ]] && find . -type f -exec grep -il  "$@" "{}" \+ ; }
randa(){
    # ARGs: [LENGTH(Default:32]
    cat /dev/urandom |tr -dc 'a-zA-Z0-9' |fold -w ${1:-32} |head -n 1
}

md5()    {( algo=$FUNCNAME ; _hash "$@" ; )}
sha()    {( algo=$FUNCNAME ; _hash "$@" ; )}
sha1()   {( algo=$FUNCNAME ; _hash "$@" ; )}
sha256() {( algo=$FUNCNAME ; _hash "$@" ; )}
sha512() {( algo=$FUNCNAME ; _hash "$@" ; )}
rmd160() {( algo=$FUNCNAME ; _hash "$@" ; )}
_hash() {
    # ARGs: PATH|STR
    print_hash(){
        #REQUIREs putclip
        printf "%s" "${@:(-1)}" # print last positional-param only
    #     [[ "$_HASH_QUIET" ]] || {
    #         [[ $(type -f putclip) ]] && putclip "${@:(-1)}" # to clipboard unless '-q'
    #     }
    }
    # quiet mode on '-q' (prepended to input)
    [[ "${1,,}" == '-q' ]] && { _HASH_QUIET=1 ; shift ; } || unset _HASH_QUIET

    if [[ "$@" && "$algo" ]]
    then
        if [[ -f "$@" ]]
        then
            # -- file --
            [[ "$_HASH_QUIET" ]] || echo $algo "[FILE] '${@##*/}' ..."
            print_hash $( openssl $algo "$*" )
        else
            # -- string --
            [[ "$_HASH_QUIET" ]] || {
                echo $algo "[STR] '$@' ..." >&2
            }
            print_hash $( echo -n "$*" |openssl $algo )
        fi
    else
        REQUIREs errMSG
        [[ ! "$@"    ]] && errMSG "$FUNCNAME FAIL @ null input"
        [[ ! "$algo" ]] && errMSG "$FUNCNAME FAIL @ null 'algo'"
    fi
}
woff2base64() { [[ "$(type -t base64)" && -f "$@" ]] && base64 -w 0 "$@"; }

#########
# Network

ip4(){ [[ $1 ]] && ip -4 -brief addr show $1 || ip -4 -brief addr; }
ip6(){ [[ $1 ]] && ip -6 -brief addr show $1 || ip -6 -brief addr; }
cidr(){ (ip4 eth0 || ip4 ens192) 2> /dev/null |awk '{print $3}'; }
scan(){ 
    case $1 in 
        "subnet"|"cidr") # Scan subnet (CIDR) for IP addresses in use.
            [[ $2 ]] && cidr="$2" || cidr="$(cidr)"
            [[ $cidr ]] || {
                echo '  Target CIDR not found. Declare it as an argument.'
                return 0
            }
            echo "=== @ CIDR: $cidr"
            nmap -sn $cidr
        ;;
        "ports"|"ip") # Scan IP address for ports in use.
            [[ $2 ]] && ip="$2" || ip="$(cidr |cut -d/ -f1)"
            [[ $ip ]] || {
                echo '  Target IP address not found. Declare it as an argument.'
                return 0
            }
            echo "=== @ IP Address: $ip"
            seq ${3:-1} ${4:-1024} \
                |xargs -IX nc -zvw 1 $ip X 2>&1 >/dev/null \
                |grep -iv fail |grep -iv refused
        ;;
        *)
            echo "  USAGE: $FUNCNAME subnet|ports [CIDR|IP] [minPORT [maxPORT]]"
        ;;
    esac
}

tls(){
    unset artifact
    case $1 in
        "cnf")
            # Make configuration file (.cnf) for CSR
            [[ $2 ]] || {
                echo "  USAGE: $FUNCNAME cnf CN"
                # ***  PRESERVE TABS of HEREDOC  ***
				cat <<-EOH
				
				Set environment variable(s) to override their default:
				
				TLS_C=US
				TLS_ST=NY
				TLS_L=Gotham
				TLS_O='Foo Inc'
				TLS_OU=DevOps
				EOH

                return 0
            }
            artifact="${2}.cnf"
            # ***  PRESERVE TABS of HEREDOC  ***
			cat <<-EOH |tee $artifact
			[req]
			prompt = no
			distinguished_name = req_dn
			req_extensions = req_ext
			[req_dn]
			CN = $2
			C  = ${TLS_C:-US}
			ST = ${TLS_ST:-NY}
			L  = ${TLS_L:-Gotham}
			O  = ${TLS_O:-Foo Inc}
			OU = ${TLS_OU:-DevOps}
			[req_ext]
			subjectAltName = @alt_names
			keyUsage = digitalSignature, keyEncipherment
			extendedKeyUsage = serverAuth, clientAuth
			[alt_names]
			DNS.1 = $2
			DNS.2 = *.$2
			EOH
            # Others under [req_ext]
            # certificatePolicies = $policy_OID
            # authorityInfoAccess = caIssuers;URI:http://example.com/ca.pem, OCSP;URI:http://ocsp.example.com
            # basicConstraints = CA:FALSE
        ;;
        "key")
            ### Generate RSA private key
            [[ $2 ]] || {
                echo "  USAGE: $FUNCNAME key CN [key-length(Default:2048)]"
                return 0
            }
            artifact=${2}.key
            openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:${3:-2048} -out $artifact
        ;;
        "csr")
            [[ $2 == "make" ]] && {
                    [[ $3 && -f $4 && -f $5 ]] && {
                        # Make CSR
                        artifact=$3.csr
                        openssl req -new -sha256 -key $5 -extensions req_ext -config $4 -out $artifact
                    } || {
                        [[ $3 && -f $4 ]] && {
                            # Make Private Key and CSR
                            artifact=$3.csr
                            openssl req -new -newkey rsa:${5:-2048} -extensions req_ext -config $4 -noenc -keyout $3.key -out $3.csr
                        } || {
                            echo "
                                USAGE:

                                    Make CSR using existing private key:
                                    $FUNCNAME csr make CN CNF_PATH PRIVATE_KEY_PATH [Key-length(Default:2048)]

                                    Make CSR and private key:
                                    $FUNCNAME csr make CN CNF_PATH [Key-length(Default:2048)]
                            "
                            return 0
                        }
                    }
                } || {
                    # Verify CSR
                    artifact="/tmp/tls.verify.${2##*/}.log"
                    [[ -f $2 ]] || {
                        echo "  USAGE: $FUNCNAME csr CSR_PATH"
                        return 0
                    }
                    openssl req -text -noout -verify -in $2 |& tee $artifact
                }
            ;;
        "server")
            # GET full-chain (-showcerts) certificate of host (server) $2 via port $3
            [[ $2 ]] || {
                echo "  USAGE: $FUNCNAME server HOST [PORT(Default:443)]"
                return 0
            }
            artifact="/tmp/tls.server.${2}_${3:-443}_full_chain_cert.log"
            # -servername limits to the declared domain name using Server Name Indication (SNI)
            openssl s_client -connect $2:${3:-443} -servername $2 -showcerts < /dev/null |& tee "$artifact"
        ;;
        "crt")
            [[ $2 == "verify" ]] && {
                # Verify the server's ca-signed certificate against the CA that signed it.
                [[ -f $3 && -f $4 ]] && {
                    artifact=/tmp/tls.crt.verify.${3##*/}.log
                    openssl verify -CAfile $3 $4 |& tee $artifact
                } || {
                    # CA_CERT_BUNDLE is path to trust-store file; concatenated CA certificates in PEM format.
                    # SERVER_CERT is path to server's full-chain certificate AKA certificate-chain file
                    echo "  USAGE: $FUNCNAME crt verify CA_CERT_BUNDLE SERVER_CERT"
                    return 0
                }
            }
            [[ $2 == "parse" ]] && {
                [[ -f $3 ]] && {
                    artifact=/tmp/tls.crt.parse.${3##*/}.log
                    openssl x509 -in $3 -text -noout |& tee $artifact 
                } || {
                    echo "  USAGE: $FUNCNAME crt parse SERVER_CERT"
                    return 0
                }
            }
        ;;
        *)
            echo ' USAGE:
                tls key         : Make RSA private key file (.key)
                tls cnf         : Make configuration file (.cnf) for CSR
                tls csr make    : Make CSR file (.csr)
                tls csr         : Verify CSR
                tls crt parse   : Parse certificate
                tls crt verify  : Verify certificate
                tls server      : Get full-chain certificate of a server
            '
        ;;
    esac
    [[ -f $artifact ]] && printf "\n  %s\n" "See: $artifact"
}

#####
# ssh

alias fpr='ssh-keygen -E md5 -lvf'
alias fprs='ssh-keygen -lvf'
hostfprs() {
    # Scan host and show fingerprints of its keys to mitigate MITM attacks.
    # Use against host's claimed fingerprint on ssh-copy-id or other 1st connect.
    [[ "$1" ]] && {
        ssh-keyscan $1 2>/dev/null |ssh-keygen -lf -
    } || {
        printf "\n%s\n" 'Usage:'
        echo "$FUNCNAME \$host (FQDN or IP address)"
    }
    printf "\n%s\n" 'Push key to host:'
    echo 'ssh-copy-id -i $keypath $ssh_user@$host'
}

######
# Meta

vars(){ declare -p |grep -E 'declare -(x|[a-z]*x)' |awk '{print $3}' |grep -v __git; }

#newest(){ find ${1:-.} -type f ! -path '*/.git/*' -printf '%T+ %P\n' |sort -r |head -n 1 |cut -d' ' -f2-; }

colors() {
    # Each is a background color and contrasting text color.
    # Usage: colors;printf "\n %s\n" "$green MESSAGE $norm"
    [[ "$TERM" ]] || return 99
    normal="$( tput sgr0 )"                       # reset
    red="$(    tput setab 1 ; tput setaf 7 )"
    yellow="$( tput setab 3 ; tput setaf 0 )"   # blk foreground
    green="$(  tput setab 2 ; tput setaf 0 )"   # blk foreground
    greenw="$( tput setab 2 ; tput setaf 7 )"   # wht foreground
    blue="$(   tput setab 4 ; tput setaf 7 )"
    gray="$(   tput setab 7 ; tput setaf 0 )" ; alias grey=gray
    aqua="$(   tput setab 6 ; tput setaf 7 )"
    aqux="$(   tput setab 6 ; tput setaf 6 )"   # hidden text
    zzz="$normal"
    norm="$normal"

}
errMSG() {
    # ARGs: MESSAGE
    [[ "$TERM" ]] && {
        colors;printf "\n $red ERROR $norm : %s\n" "$@"
    } || {
        printf "\n %s\n" " ERROR : $@"
    }
    return 99
}
REQUIREs(){
    # ARGs: FUNCNAME1 [FUNCNAME2 ...]
    # function[s] exist test; exit on fail; $? is 86 on fail, else 0
    declare flag
    for func in "$@"
    do  # exist-test ; append flag on fail
        [[ "$( type -t $func )" ]] || flag="${flag}'${func}', "
    done
    [[ "$flag" ]] && { # inform of calling-function and non-existent functions
        flag="${flag%,*}" ; errMSG "'${FUNCNAME[1]}' REQUIREs function[s] that do NOT EXIST ..."
        printf '\n %s\n' "$flag"
        # return|exit [86] on fail per @ 1x-bash or not
        #[[ $PPID -eq $_PID_1xSHELL ]] && return 86 || exit 86 # nope; pppppids are a clusterfuck
        return 86
    }
    return 0
}
putclip() {
    # ARGs: STR
    # $@ => clipboard [erases it on null input]
    if [[ ! "$_CLIPBOARD" ]] # set clipboard per OS, once per Env.
    then
        # Win7: clip; Linux: xclip -selection c; OSX: pbcopy; Cygwin: /dev/clipboard
        for i in clip xclip pbcopy
        do
            [[ "$( type -t $i )" ]] && _CLIPBOARD="$i"
        done
        [[ "$OSTYPE" == 'cygwin' ]]    && _CLIPBOARD='/dev/clipboard'
        [[ "$OSTYPE" == 'msys' ]]      && _CLIPBOARD='/dev/clipboard'
        [[ "$_CLIPBOARD" == 'xclip' ]] && _CLIPBOARD='xclip -i -f -silent -selection clipboard'
        # '-i -f -silent' and null redirect is workaround for command-sustitution case ['-loop #' bug]
    fi
    # validate clipboard; rpt & exit on fail
    [[ "$_CLIPBOARD" ]] || { errMSG "$FUNCNAME[clipboard-not-exist]" ; return 86 ; }
    # put :: $@ => clipboard
    [[ "$@" ]] && {
        [[ "$OSTYPE" == 'linux-gnu' ]] && { printf "$*" | $_CLIPBOARD > /dev/null; true; } || { printf "$*" > $_CLIPBOARD; true; }
    } || {
        [[ "$OSTYPE" == 'linux-gnu' ]] && { : | $_CLIPBOARD > /dev/null; true; } || { : > $_CLIPBOARD; }
    }
}
x(){
    # Exit shell; show post-exist shell lvl;
    # clear user history if @ 1st shell
    clear #; shlvl
    [[ "$BASHPID" == "$_PID_1xSHELL" ]] && {
        history -c; echo > "$_HOME/.bash_history" # clear history
        github ssh kill # kill all ssh-agent processes
    }
    exit > /dev/null 2>&1
}
shlvl(){
    # ARGs: [{msg}]
    # Show shell level [and message]
    colors; [[ "$@" ]] && _msg=": $@" || unset _msg
    [[ "${FUNCNAME[1]}" == 'x' ]] && _shlvl=$(( $SHLVL - 1 )) || _shlvl=$SHLVL
    [[ "$_shlvl" == "1" ]] && [[ "$PPID" == "$_PID_1xSHELL" ]] && { printf "\n %s\n" "$red $(( $_shlvl ))x ${SHELL##*/} $norm $_msg" ; } || { printf "\n %s\n" "$(( $_shlvl ))x ${SHELL##*/} $_msg" ; }
}
envsans(){
    # Print environment variables without functions
    declare -p |grep -E '^declare -x [^=]+=' |sed 's,",,g' |awk '{print $3}'
    printf "\n\t(%s)\n" 'Environment variables containing special characters may not have printed accurately.'
}

set +a  # END export

## End here if not interactive
# [[ "$-" != *i* ]] && return
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"

