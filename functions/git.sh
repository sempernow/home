# source /etc/profile.d/git.sh
################################
# Configure bash shell for Git
################################
[[ "$isBashGitSourced" ]] && return
isBashGitSourced=1

[[ "$(type -t git)" ]] || return

set -a # Export all

git_bash_completion=/usr/share/bash-completion/completions/git
[[ -f $git_bash_completion ]] && source $git_bash_completion

alias gcfg='git config -l'
ga(){ git add . ; git status; }
gb(){ git branch --all;echo;git remote -v; }
gbd(){
    [[ "$1" ]] || return 90
    [[ "$(git branch --all |grep $1)" ]] || return 91
    git branch -D $1                # Local
    git push origin --delete $1     # Remote
}
gc(){ # commit -m [MSG]
    newest(){
        TZ=Zulu find . -type f ! -path '*/.git/*' -printf '%T+ %P @ %TY-%Tm-%TdT%TH:%TMZ\n' \
            |sort -r |head -n 1 |cut -d' ' -f2-
    }
    export -f newest
    [[ -d ./.git ]] || git init
    [[ "$@" ]] && _m="$@" || _m="$(newest)"
    git add .;git add -u;git commit -m "$_m";gl
}
gch(){ # checkout [-b NEW]
    [[ "$@" ]] && _b="$@" || { _b="$(date '+%H.%M.%S')"; _b="${_b:0:5}"; }
    [[ "$(git branch |grep "$_b")" ]] && git checkout "$_b" || git checkout -b "$_b"
}
gl(){ # All as oneliners, or n ($1) with stats
    clear && [[ "$1" ]] && {
        git log --stat -n $1
    } || {
        git log --oneline
    }
}
gpf(){ git push --force-with-lease; } # force required after rebase
gr(){
    count_commits=$(( $( git rev-list --count HEAD ) - 1 ))
    (( "$count_commits" < 2 )) && {
        gl; printf "\n%s\n" 'Not enough commits to squash.'
    } || {
        echo "
            Interactive rebase, squashing $count_commits (max) commits.
            
            Launches default editor. Replace all 'pick' with 's',
            except 1st listed (max squash).
            Subsequent push may require "'`git push --force`.'"
            Abort (on fail): "'`git rebase --abort` .'

        git rebase -i HEAD~$count_commits
    }
}
grs(){
    echo "
        Reset, squash everything regardless. Preserve only the newest commit.
        Subsequent push may require "'`git push --force`.'

    count_commits=$(( $( git rev-list --count HEAD ) - 1 ))
    git reset --soft HEAD~$count_commits
}
gs(){ git status; }

set +a # End export all

## End here if not interactive
[[ -z "$PS1" ]] && return 0

[[ "$BASH_SOURCE" ]] && echo "@ $BASH_SOURCE"

