# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2025 NXP
#

#
# $1=pkg_name $2=url $3=branch/tag/commit
#
define dl_from_github
    echo "[INFO] Downloading $(1)_$(3).tar.gz"; \
	rm -f $(FBDIR)/dl/$(1)_$(3).tar.gz && \
	mkdir -p $(FBDIR)/dl && \
	md5=$(repo_$(1)_md5) && \
	if [ -n "$${md5}" ]; then \
		if ! python3 $(FBDIR)/tools/dl_github.py \
			--dl-dir=$(FBDIR)/dl \
			--url=$(2) \
			--version=$(3) \
			--subdir=$(1) \
			--hash=$$md5; then \
			echo "Downloading with md5 failed, fallback to clone "; \
			$(call rawgit,$(1),$(2),$(3),submod) || { echo "Clone failed"; exit 1; }; \
		fi \
	else \
		if ! python3 $(FBDIR)/tools/dl_github.py \
			--dl-dir=$(FBDIR)/dl \
			--url=$(2) \
			--version=$(3) \
			--subdir=$(1); then \
			echo "Downloading without md5 failed, fallback to clone "; \
			$(call rawgit,$(1),$(2),$(3),submod) || { echo "Clone failed"; exit 1; }; \
		fi \
	fi && \
	echo "[INFO] Downloading Done" $(LOG_MUTE)
endef

#
# $1=pkg_name $2=url $3=branch/tag/commit $4={git: keep git info}
#
define rawgit
	echo "[INFO] Cloning $(1) (with submodules)  "; \
	rm -rf /tmp/$(1) && \
	_TMP_DIR=/tmp/$(1) && \
	mkdir -p $${_TMP_DIR} && \
	\
	git clone $(2) $${_TMP_DIR} $(LOG_MUTE) && \
	cd $${_TMP_DIR} && \
	git checkout $(3) $(LOG_MUTE) && \
	git submodule update --init --recursive $(LOG_MUTE) && \
	if [  $(4) = "submod" ]; then \
		rm -rf .git .gitmodules .github; \
	fi && \
	cd .. && \
	echo "[INFO] Creating package $(1)_$(3).tar.gz" $(LOG_MUTE) && \
	mkdir -p $(FBDIR)/dl && \
	tar -czf $(1)_$(3).tar.gz $(1)/ && \
	mv $(1)_$(3).tar.gz $(FBDIR)/dl && \
	rm -rf /tmp/$(1) && \
	echo "[INFO] Package created: $(1)_$(3).tar.gz" $(LOG_MUTE)
endef

#
# $1=package_name $2=dir $3= {submod: clone submodules, git: keep .git info, other: download .tar.gz only}
#
define download_repo
	_URL=$(repo_$(1)_url) && \
	_VER=$(or $(repo_$(1)_ver),$(DEFAULT_REPO_TAG)) && \
	\
	if [ -z "$${_URL}" ]; then \
		echo $${_URL} is not defined ; exit 1; \
	fi && \
	if [ -z "$${_VER}" ]; then \
		echo Repo version $${_VER}is not defined ; exit 1; \
	fi && \
	\
	mkdir -p $(PKGDIR)/$(2) && \
	_PKG_FILE=${FBDIR}/dl/${1}_$${_VER}.tar.gz && \
	_TARGET_DIR=$(PKGDIR)/$(2)/$(1) && \
	\
	if [ -s "$${_PKG_FILE}" ]; then \
		echo "[INFO] Package exists: $(1)_$${_VER} " $(LOG_MUTE); \
	else \
		case "$(3)" in \
			submod|git) \
				$(call rawgit,$(1),$${_URL},$${_VER},$(3)) || { echo git clone failed; exit 1; } ;; \
			*) \
				$(call dl_from_github,$(1),$${_URL},$${_VER}) || { echo Download failed; exit 1; } ;; \
		esac; \
	fi && \
	\
	if [ -d "$${_TARGET_DIR}" ]; then \
		echo "[INFO] Target already exists" $(LOG_MUTE); \
	else \
		echo "[INFO] Extracting: $(1) "; \
		tar -xf "$${_PKG_FILE}" -C "$(PKGDIR)/$(2)" || { echo "Extraction failed"; exit 1; }; \
	fi
endef


#
# $1=package_name $2=dir
#
define clone_repo
	if [ -d $(PKGDIR)/$(2)/$(1) ]; then \
		echo "[INFO] Target already exists" $(LOG_MUTE); \
	else \
		echo "[INFO] Clone $(1) "; \
		cd $(PKGDIR)/$(2) && \
		git clone $(repo_$(1)_url) $(1) $(LOG_MUTE) && \
		cd $(1) && git submodule update --init --recursive $(LOG_MUTE) && \
		echo "[INFO] Clone DONE."; \
	fi
endef

#
# define the default wget command
#

WGET := wget --no-check-certificate --tries=3 --timeout=100 --continue --progress=bar --no-verbose --show-progress

#
# wrap the wget command, MD5SUM check ??
# $1=package_link_name $2=package_target_name
#
define dl_by_wget
	if [ -f $(FBDIR)/dl/$(2) ]; then \
		echo "[INFO] $(1) already exists" $(LOG_MUTE); \
	else \
		echo "[INFO] Downloading $(1)"; \
		mkdir -p $(FBDIR)/dl /tmp && \
		rm -f /tmp/$(2) && \
		$(WGET) $(repo_$(1)_url)  -O /tmp/$(2) $(LOG_MUTE) && \
		if [ $$? -ne 0 ]; then \
			echo "Downloading $(1) failed." && exit 1; \
		fi && \
		if [ -z "$(repo_$(1)_md5)" ]; then \
			echo "[WARN] No expected MD5 for $(1); skip checksum." $(LOG_MUTE); \
		else \
			md5=$$(md5sum /tmp/$(2) | awk '{print $$1}') && \
			if [ "$$md5" != "$(repo_$(1)_md5)" ]; then \
				echo "[ERROR] MD5 mismatch for $(1): expected $(repo_$(1)_md5), got $$md5" && \
				rm -f /tmp/$(2) && \
				exit 1; \
			fi \
		fi && \
		mv /tmp/$(2) $(FBDIR)/dl && \
		echo "[INFO] Downloading Done" $(LOG_MUTE); \
	fi
endef

