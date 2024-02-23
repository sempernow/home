##############################################################################
## Makefile.settings : Environment Variables for Makefile(s) …
#include Makefile.settings

##############################################################################
## Environment variable rules:
## - Any TRAILING whitespace KILLS its variable value and may break recipes.
## - ESCAPE only that required by the shell (bash).
## - Environment hierarchy:
##   - Makefile environment OVERRIDEs OS environment lest set using `?=`.
##  	  - `FOO ?= bar` is overridden by parent setting; `export FOO=new`.
##  	  - `FOO :=`bar` is NOT overridden by parent setting.
##   - Docker YAML `env_file:` OVERRIDEs OS and Makefile environments.
##   - Docker YAML `environment:` OVERRIDEs YAML `env_file:`.
##   - CMD-inline OVERRIDEs ALL REGARDLESS; `make recipeX FOO=new BAR=new2`.

##############################################################################
## $(INFO) : Usage : `$(INFO) 'What ever'` prints a stylized "@ What ever".
SHELL   := /bin/bash
YELLOW  := "\e[1;33m"
RESTORE := "\e[0m"
INFO    := @bash -c 'printf $(YELLOW);echo "@ $$1";printf $(RESTORE)' MESSAGE

##############################################################################
## Project Meta

export PRJ_ROOT := $(shell pwd)

export GIT_PROMPT_DIR := /usr/share/git-core/contrib/completion
export HAS_WSL        := $(shell type -t wsl.exe)
export IS_EDN         := $(shell echo $$no_proxy |grep northgrum.com)

##############################################################################
## Recipes : Meta

menu :
	$(INFO) 'Install'
	@echo "sync      : Sync .local/bin to ~/.bin and /usr/local/bin"
	@echo "user      : Configure bash shell for this user (${USER})."
	@echo "all       : Configure bash shell for all users."
	
	$(INFO) 'Demo : docker exec -it NAME [ba]sh'
	@echo "ubox      : docker run -d … ubuntu …"
	@echo "bbox      : docker run -d … busybox …"
	@echo "abox      : docker run -d … alpine …"
	@echo "rbox      : docker run -d … almalinux …"

	$(INFO) 'Meta'
	@echo "html      : .MD -> .HTML"
	@echo "perms     : find . -type f … -exec chmod …"

env :
	@echo "IS_EDN  : ${IS_EDN}"
	@echo "HAS_WSL : ${HAS_WSL}"

sync synch :
	bash make.recipes.sh sync_bins

user : perms
	bash make.recipes.sh user

all : perms
	bash make.recipes.sh all

ubox :
	docker run --rm -d --name ubox -v ${PRJ_ROOT}:/root -w /root ubuntu sleep 1d 

bbox :
	docker run --rm -d --name bbox -v ${PRJ_ROOT}:/root -w /root busybox sleep 1d 

abox :
	docker run --rm -d --name abox -v ${PRJ_ROOT}:/root -w /root alpine sleep 1d 

rbox :
	docker run --rm -d --name rbox -v ${PRJ_ROOT}:/root -w /root almalinux:8 sleep 1d 

html : md2html perms

md2html : makehtml perms

makehtml :
	find . -type f -iname '*.md' -exec md2html.exe "{}" \;

perms :
	find . -type f ! -path './.git/*' -exec chmod 0644 "{}" \+
	find . -type f ! -path './.git/*' -iname '*.sh' -exec chmod 0755 "{}" \+
	chmod 0755 .local/bin/*
	chmod 0644 etc_profile.d/*.sh

getgit :
	wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
	wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
