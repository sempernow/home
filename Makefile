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
export IS_EDN         := $(shell echo $$no_proxy |grep northgrum.com)
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
	echo "IS_EDN : ${IS_EDN}"
	echo "HAS_WSL: ${HAS_WSL}"
	[[ "${HAS_WSL}" ]] && echo okay || echo fail

user : perms
	find . -maxdepth 1 -type f -iname '.*' -exec cp -p {} ~/ \;
	chmod 0755 .local/bin/*
	cp -rp .local/bin/* ~/.local/bin
	[[ "${HAS_WSL}" ]]  && sudo cp -p ./etc_profile.d/win.sh .bashrc_win || true
	[[ "${IS_EDN}" ]]  && sudo cp -p ./etc_profile.d/edn.sh .bashrc_edn || true
	chmod 0644 ~/.profile
	chmod 0644 ~/.bash*
	chmod 0644 ~/.gitignor*
	chmod 0644 ~/.gitconf*
	chmod 0644 ~/.vim*
	chmod 0755 ~/.*.sh

all : perms
	sudo rm /etc/profile.d/${USER}-??-*.sh
	sudo cp -p ./.bashrc /etc/profile.d/${USER}-01-bashrc.sh
	sudo cp -p ./.bash_functions /etc/profile.d/${USER}-02-bash_functions.sh
	sudo cp -p ./etc_profile.d/*.sh /etc/profile.d/
	[[ "${HAS_WSL}" ]] \
		&& sudo mv /etc/profile.d/win.sh /etc/profile.d/${USER}-00-bashrc_win.sh \
		|| sudo rm /etc/profile.d/win.sh
	[[ "${IS_EDN}" ]] \
		&& sudo mv /etc/profile.d/edn.sh /etc/profile.d/${USER}-00-bashrc_edn.sh \
		|| sudo rm /etc/profile.d/edn.sh
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
