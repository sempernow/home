##############################################################################
# Makefile.settings : Environment Variables for Makefile(s)
##############################################################################
# Environment variable rules:
# - Any TRAILING whitespace KILLS its variable value and may break recipes.
# - ESCAPE only that required by the shell (bash).
# - Environment Hierarchy:
#   - Makefile environment OVERRIDEs OS environment lest set using `?=`.
#  	  - `FOO ?= bar` is overridden by parent setting.
#  	  - `FOO :=`bar` is NOT overridden by parent setting.
#   - Docker YAML `env_file:` OVERRIDEs OS and Makefile environments.
#   - Docker YAML `environment:` OVERRIDEs YAML `env_file:`.
#   - CMDline OVERRIDEs ALL, e.g., `make recipeX FOO=newValue BAR=newToo`.
##############################################################################
#include Makefile.settings

##############################################################################
# $(INFO) : Usage : `$(INFO) 'What ever'` prints a stylized "@ What ever".
SHELL   := /bin/bash
YELLOW  := "\e[1;33m"
RESTORE := "\e[0m"
INFO    := @bash -c 'printf $(YELLOW);echo "@ $$1";printf $(RESTORE)' MESSAGE

##############################################################################
# Project Meta

export PRJ_ROOT := $(shell pwd)

export GIT_PROMPT_DIR := /usr/share/git-core/contrib/completion
export HAS_WSL        := $(shell type -t wsl.exe)
##############################################################################
# Recipes : Meta

menu :
	$(INFO) 'Install'
	@echo "user      : All The Things for this user (${USER})."
	@echo "all       : All The Things for all users."
	
	$(INFO) 'Demo : docker exec -it NAME [ba]sh'
	@echo "ubox      : docker run -d ... ubuntu sleep 1d"
	@echo "bbox      : docker run -d ... busybox sleep 1d"

	$(INFO) 'Meta'
	@echo "html      : .MD -> .HTML"
	@echo "perms     : find . -type f ... -exec chmod ..."
	
test :
	echo ${HAS_WSL}
	[[ "${HAS_WSL}" ]] && echo okay || echo fail

user :
	find . -maxdepth 1 -type f -iname '.*' -exec cp -p {} ~/ \;
	chmod 0755 .local/bin/*
	cp -rp .local/bin/* ~/.local/bin
	chmod 0644 ~/.profile
	chmod 0644 ~/.bash*
	chmod 0644 ~/.gitig*
	chmod 0644 ~/.gitco*
	chmod 0644 ~/.vim*
	chmod 0755 ~/.*.sh 

all :
	sudo cp -p ./.bashrc /etc/profile.d/${USER}-01-bashrc.sh
	sudo cp -p ./.bash_functions /etc/profile.d/${USER}-02-bash_functions.sh
	[[ "${HAS_WSL}" ]] && sudo cp -p ./.bash_win /etc/profile.d/${USER}-00-bash_win.sh
	sudo chmod 0644 /etc/profile.d/${USER}-*.sh
	sudo mkdir -p /usr/local/bin
	sudo cp -p .local/bin/* /usr/local/bin
	sudo mkdir -p ${GIT_PROMPT_DIR}
	sudo cp -p ./.git-prompt.sh ${GIT_PROMPT_DIR}/git-prompt.sh
	sudo mkdir -p /etc/vim
	sudo cp -p ./.vimrc /etc/vim/vimrc.local

ubox :
	docker run --rm -d --name ubox -v ${PRJ_ROOT}:/root -w /root ubuntu sleep 1d 

bbox :
	docker run --rm -d --name bbox -v ${PRJ_ROOT}:/root -w /root busybox sleep 1d 

abox :
	docker run --rm -d --name abox -v ${PRJ_ROOT}:/root -w /root alpine sleep 1d 

rbox :
	docker run --rm -d --name abox -v ${PRJ_ROOT}:/root -w /root almalinux:8 sleep 1d 

html : md2html perms

md2html :
	find . -type f -iname '*.md' -exec md2html.exe "{}" \;

perms :
	find . -type f ! -path './.git/*' -exec chmod 0644 "{}" \+
	find . -type f  -iname '*.sh' -exec chmod 0755 "{}" \+
	find . -type f  -iname '*.sh' -exec chmod 0755 "{}" \+
	chmod 0755 .local/bin/*

getgit :
	wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
	wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash