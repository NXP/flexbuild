# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2025 NXP
#

#
# $1=pkg_name $2=url $3=branch/tag/commit
#
define dl_from_github
    echo "[INFO] Downloading $(1)_$(3).tar.xz..."; \
	rm -f $(FBDIR)/dl/$(1)_$(3).tar.xz && \
	mkdir -p $(FBDIR)/dl && \
	md5=$(repo_$(1)_md5) && \
	if [ -n "$${md5}" ]; then \
		python3 $(FBDIR)/tools/dl_github_archive.py \
			--dl-dir=$(FBDIR)/dl \
			--url=$(2) \
			--version=$(3) \
			--subdir=$(1) \
			--source="$(1)_$(3).tar.xz" \
			--hash=$$md5 \
			|| { echo Download with md5 failed; exit 1; } \
	else \
		python3 $(FBDIR)/tools/dl_github_archive.py \
			--dl-dir=$(FBDIR)/dl \
			--url=$(2) \
			--version=$(3) \
			--subdir=$(1) \
			--source="$(1)_$(3).tar.xz" \
			|| { echo Download without md5 failed; exit 1; } \
	fi
endef

#
# $1=pkg_name $2=url $3=branch/tag/commit $4={git: keep git info}
#
define rawgit
	echo "[INFO] Cloning $(1) (with submodules) ... "; \
	rm -rf $(FBDIR)/tmp/$(1) && \
	_TMP_DIR=$(FBDIR)/tmp/$(1) && \
	mkdir -p $${_TMP_DIR} && \
	\
	git clone --recursive $(2) $${_TMP_DIR} $(LOG_MUTE) && \
	cd $${_TMP_DIR} && \
	git checkout $(3) $(LOG_MUTE) && \
	git submodule update --init --recursive $(LOG_MUTE) && \
	if [  $(4) = "submod" ]; then \
		rm -rf .git .gitmodules .github; \
	fi && \
	cd .. && \
	echo "[INFO] Creating package $(1)_$(3).tar.xz" $(LOG_MUTE) && \
	mkdir -p $(FBDIR)/dl && \
	tar -cJf $(1)_$(3).tar.xz $(1)/ && \
	mv $(1)_$(3).tar.xz $(FBDIR)/dl && \
	rm -rf $(FBDIR)/tmp/$(1); \
	echo "[INFO] Package created: $(1)_$(3).tar.xz" $(LOG_MUTE)
endef

#
# $1=package_name $2=dir $3= {submod: clone submodules, git: keep .git info, other: download .tar.xz only}
#
define download_repo
	_URL=$(repo_$(1)_url); \
	_VER=$(or $(repo_$(1)_ver),$(DEFAULT_REPO_TAG)); \
	\
	[ -z "$${_URL}" ] && { echo $${_URL} is not defined ; exit 1; }; \
	[ -z "$${_VER}" ] && { echo Repo version $${_VER}is not defined ; exit 1; }; \
	\
	_PKG_FILE=${FBDIR}/dl/${1}_$${_VER}.tar.xz; \
	_TARGET_DIR=$(PKGDIR)/$(2)/$(1); \
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

