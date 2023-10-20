#########################################
#
# Copyright 2017-2019 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
#########################################

SHELL=/bin/bash


define repo-mngr
	for tree in $2; do \
	    branch=`grep -E "^repo_$${tree}_branch" $(FBDIR)/configs/$(CONFIGLIST) | cut -d= -f2` && branch=`echo $$branch | sed 's/\"//g'`; \
	    commit=`grep -E "^repo_$${tree}_commit" $(FBDIR)/configs/$(CONFIGLIST) | cut -d= -f2` && commit=`echo $$commit | sed 's/\"//g'`; \
	    tag=`grep -E "^repo_$${tree}_tag" $(FBDIR)/configs/$(CONFIGLIST) | cut -d= -f2` && tag=`echo $$tag | sed 's/\"//g'`; \
	    repourl=`grep -E "^repo_$${tree}_url" $(FBDIR)/configs/$(CONFIGLIST) | cut -d= -f2` && repourl=`echo $$repourl | sed 's/\"//g'` && \
	    if [ -z "$$tag" -a $(UPDATE_REPO_PER_TAG) = y ] && ! echo "$(REPO_TAG_EXCLUDE)" | grep -q " $$tree "; then tag=$(DEFAULT_REPO_TAG); fi; \
	    repo_en=`grep -iE "^CONFIG_BUILD_$${tree}" $(FBDIR)/configs/$(CONFIGLIST) | cut -d= -f2`; \
	    if [ $$tree = linux ]; then tree=$(KERNEL_TREE); fi; \
	    if [ -n "$$repourl" ]; then echo -e "\nrepo: $$tree"; fi && \
	    if [ $(UPDATE_REPO_PER_TAG) = y ]; then \
		[ -n "$$repourl" -a -n "$$tag" ] && echo tag: $$tag; \
		if [ -n "$$branch" ] && echo "$(REPO_TAG_EXCLUDE)" | grep -q " $$tree "; then echo branch: $$branch; fi; \
	    elif [ $(UPDATE_REPO_PER_BRANCH) = y ]; then \
		[ -n "$$repourl" -a -n "$$branch" ] && echo branch: $$branch; \
		if [ -n "$$repourl" -a -n "$$tag" ] && echo "$(REPO_BRANCH_EXCLUDE)" | grep -q " $$tree "; then echo tag: $$tag; fi; \
	    elif [ $(UPDATE_REPO_PER_COMMIT) = y ]; then \
		[ -n "$$repourl" -a -n "$$commit" ] && echo commit: $$commit; \
	    fi && \
	    tree=$(PKGDIR)/$3/$$tree && \
	    if [ -n "$$repourl" ] && [ -d $$tree -o -L $$tree ]; then \
	        if [ $1 = update -a -n "$$branch" ]; then if [ "$${repo_en}" = "n" ]; then echo $$tree disabled!; \
		    else cd $$tree && if [ "`cat .git/HEAD | cut -d/ -f3`" != "$$branch" ]; \
		    then if git show-ref --verify --quiet refs/heads/$$branch; \
		    then git checkout $$branch && git pull origin $$branch; \
		    else git checkout remotes/origin/$$branch -b $$branch;fi; else git pull origin $$branch; fi || exit 1; cd -; fi; \
		elif [ $1 = update -a -z "$$branch" -a -n "$$tag" ]; then if [ "$${repo_en}" = "n" ]; then echo $$tree disabled!; \
		    else cd $$tree && if ! git show-ref --verify --quiet refs/tags/$$tag; then git pull||true;fi && \
		    if [ "`cat .git/HEAD | cut -d/ -f3`" != "$$tag" ]; then \
		    if git show-ref --verify --quiet refs/heads/$$tag; then git checkout $$tag; else git checkout $$tag -b $$tag;fi;fi || exit 1; cd -; fi; \
		elif [ $1 = tag -a -n "$$tag" ]; then if [ "$${repo_en}" = "n" ]; then echo $$tree disabled!; \
		    else cd $$tree && if ! git show-ref --verify --quiet refs/tags/$$tag; then \
		    git fetch --tags || true;fi && if [ "`cat .git/HEAD | cut -d/ -f3`" != "$$tag" ]; then if git show-ref --verify --quiet refs/heads/$$tag; \
		    then git checkout $$tag; else git checkout -f $$tag -b $$tag;fi;fi || exit 1; cd -; fi; \
		elif [ $1 = commit -a -n "$$commit" ]; then cd $$tree && git config advice.objectNameWarning false && \
		    if git show-ref --verify --quiet refs/heads/$$commit; then git checkout $$commit; else git checkout $$commit -b $$commit; fi || exit 1; cd -; \
                elif [ $1 = branch -a -n "$$branch" ]; then if [ "$${repo_en}" = "n" ]; then echo $$tree disabled!; \
                    else cd $$tree && git checkout $$branch || exit 1; cd -; fi; \
		elif [ $1 = update -a -n "$$commit" ]; then echo commit = $$commit; fi;\
	    elif [ -n "$$repourl" -a $1 = fetch ]; then \
	        if [ "$${repo_en}" = "n" ]; then echo $$tree disabled!; \
		elif [ -n "$$tag" -a $(UPDATE_REPO_PER_TAG) = y ] || [ -n "$$tag" -a -z "$$branch" -a -z "$$commit" ]; then \
		    git clone --recurse-submodules $$repourl $$tree && cd $$tree && git checkout -f $$tag -b $$tag && cd -; \
		elif [ -n "$$commit" -a $(UPDATE_REPO_PER_COMMIT) = y ] || [ -n "$$commit" -a -z "$$branch" -a -z "$$tag" ]; then \
		    git clone --recurse-submodules $$repourl $$tree && cd $$tree && git checkout -f $$commit -b $$commit && cd -; \
		elif [ -n "$$branch" -a $(UPDATE_REPO_PER_BRANCH) = y ] || [ -z "$$tag" -a -n "$$branch" -a $(UPDATE_REPO_PER_TAG) = y ]; then \
		    git clone --recurse-submodules $$repourl $$tree -b $$branch; \
		else \
		    $(call fbprint_w,"`basename $$tree`: missing repo branch/tag info in configs/$(CFGLISTYML)"); \
		fi; \
	    fi; \
	done
endef


red=\e[0;41m
RED=\e[1;31m
green=\e[0;32m
GREEN=\e[1;32m
yellow=\e[5;43m
YELLOW=\e[1;33m
NC=\e[0m

define fbprint_b
        echo -e "$(green)\nBuilding $1 ... $(NC)"
endef
define fbprint_n
	echo -e "$(green)$1 $(NC)"
endef
define fbprint_d
	echo -e "$(GREEN)$1  [Done] $(NC)"
endef
define fbprint_w
        echo -e "$(YELLOW)$1 $(NC)"
endef
define fbprint_e
        echo -e "$(red)$1 $(NC)"
endef
