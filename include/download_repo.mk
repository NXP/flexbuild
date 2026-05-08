# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2025-2026 NXP
#

#
# $1=pkg_name $2=url $3=branch/tag/commit
#
define dl_from_github
	echo "[INFO] Downloading $(1)_$(3).tar.gz"
	rm -f $(FBDIR)/dl/$(1)_$(3).tar.gz
	mkdir -p $(FBDIR)/dl

	md5_val=$(repo_$(1)_md5)
	hash_arg=""
	[ -n "$${md5_val}" ] && hash_arg="--hash=$${md5_val}"

	if ! python3 $(FBDIR)/tools/dl_github.py --dl-dir=$(FBDIR)/dl --url=$(2) --version=$(3) --subdir=$(1) $${hash_arg}; then
		echo "Downloading with md5 failed, fallback to clone "
		$(call rawgit,$(1),$(2),$(3),submod) || { echo "Clone $(1) failed"; exit 1; }
	fi

	echo "[INFO] Downloading Done" $(LOG_MUTE)
endef

#
# $1=pkg_name $2=url $3=branch/tag/commit $4={git: keep git info}
#
define rawgit
	echo "[INFO] Cloning $(1) (with submodules)  "
	rm -rf /tmp/$(1)
	_TMP_DIR=/tmp/$(1)

	git clone $(2) $${_TMP_DIR} $(LOG_MUTE) || {
		echo "[ERROR] git clone failed: $(1)"
		exit 1
	}

	cd "$${_TMP_DIR}"
	git checkout $(3) $(LOG_MUTE) || {
		echo "[ERROR] git checkout $(3) failed for $(1)"
		exit 1
	}

	git submodule update --init --recursive $(LOG_MUTE) || {
		echo "[ERROR] submodule update failed for $(1)"
		exit 1
	}
	if [ "$(4)" = "submod" ]; then
		rm -rf .git .gitmodules .github
	fi

	cd /tmp
	echo "[INFO] Creating package $(1)_$(3).tar.gz" $(LOG_MUTE)
	mkdir -p $(FBDIR)/dl
	tar -czf "$(1)_$(3).tar.gz" "$(1)/" || {
		echo "[ERROR] tar failed for $(1)"
		exit 1
	}

	mv "$(1)_$(3).tar.gz" "$(FBDIR)/dl"
	rm -rf /tmp/$(1)
	echo "[INFO] Package created: $(1)_$(3).tar.gz" $(LOG_MUTE)
endef
#
# $1=package_name $2=dir $3= {submod: clone submodules, git: keep .git info, other: download .tar.gz only}
#
define _download_repo_logic
	_URL=$(repo_$(1)_url)
	_VER=$(or $(repo_$(1)_ver),$(DEFAULT_REPO_TAG))

	[ -z "$${_URL}" ] && { echo "$(1) url undefined"; exit 1; }

	_PKG_FILE=${FBDIR}/dl/${1}_$${_VER}.tar.gz

	_NEED_DL=1
	if [ -s "$${_PKG_FILE}" ] && tar -tzf "$${_PKG_FILE}" >/dev/null 2>&1; then
		echo "[INFO] Package exists and valid: $(1)_$${_VER} " $(LOG_MUTE)
		 _NEED_DL=0
	fi

	if [ "$${_NEED_DL}" = "1" ]; then
		rm -f "$${_PKG_FILE}"
		if [ "$(CONFIG_KEEP_GIT)" = "y" ]; then
			$(call rawgit,$(1),$${_URL},$${_VER},git)
		else
			case "$(3)" in
				submod|git) $(call rawgit,$(1),$${_URL},$${_VER},$(3)) ;;
				*)          $(call dl_from_github,$(1),$${_URL},$${_VER}) ;;
			esac
		fi || exit 1
	fi

	if [ ! -d "$(PKGDIR)/$(2)/$(1)" ]; then
		echo "[INFO] Extracting: $(1) "
		mkdir -p $(PKGDIR)/$(2)
		tar -xf "$${_PKG_FILE}" -C "$(PKGDIR)/$(2)" || exit 1
	fi
endef

#
# wrap the download_repo command with flock protection for parallel builds
# $1=package_name $2=dir $3= {submod: clone submodules, git: keep .git info, other: download .tar.gz only}
#
define download_repo
	@_VER=$(or $(repo_$(1)_ver),$(DEFAULT_REPO_TAG))
	mkdir -p $(FBDIR)/dl $(FBDIR)/logs
	flock $(FBDIR)/logs/.$(1)_$${_VER}.tar.gz.flock -c '$(subst ','\'',$(call _download_repo_logic,$(1),$(2),$(3)))'
endef

#
# $1=package_name $2=dir
#
define clone_repo
	@if [ -d $(PKGDIR)/$(2)/$(1) ]; then
		echo "[INFO] Target already exists" $(LOG_MUTE)
	else
		echo "[INFO] Clone $(1) "
		cd $(PKGDIR)/$(2)
		git clone $(repo_$(1)_url) $(1) $(LOG_MUTE)
		cd $(1) && git submodule update --init --recursive $(LOG_MUTE)
		echo "[INFO] Clone DONE."
	fi
endef

#
# define the default wget command
#

WGET := wget --no-check-certificate --tries=3 --timeout=100 --continue --progress=bar --no-verbose --show-progress
#
# $1=package_link_name $2=package_target_name
#
define _dl_by_wget_logic
	if [ -f $(FBDIR)/dl/$(2) ]; then
		echo "[INFO] $(1) already exists" $(LOG_MUTE)
	else
		echo "[INFO] Downloading $(1)"
		mkdir -p $(FBDIR)/dl /tmp
		rm -f /tmp/$(2)

		$(WGET) "$(repo_$(1)_url)" -O "/tmp/$(2)" $(LOG_MUTE) || { echo "Download $(1) error"; exit 1; }
		_EXPECTED_MD5="$(repo_$(1)_md5)"
		if [ -z "$${_EXPECTED_MD5}" ]; then
			echo "[WARN] No expected MD5 for $(1); skip checksum." $(LOG_MUTE)
		else
			actual_md5=$$(md5sum "/tmp/$(2)" | cut -d' ' -f1)
			if [ "$${actual_md5}" != "$${_EXPECTED_MD5}" ]; then
				echo "[ERROR] MD5 mismatch for $(1): expected $${_EXPECTED_MD5}, got $${actual_md5}"
				rm -f /tmp/$(2)
				exit 1
			fi
		fi

		mv "/tmp/$(2)" "$(FBDIR)/dl/$(2)"
		echo "[INFO] Downloading Done" $(LOG_MUTE)
	fi
endef
#
# wrap the wget command with flock protection for parallel builds
# $1=package_link_name $2=package_target_name
#
define dl_by_wget
	@mkdir -p $(FBDIR)/dl $(FBDIR)/logs
	flock "$(FBDIR)/logs/.$(2).flock" -c '$(subst ','\'',$(call _dl_by_wget_logic,$(1),$(2)))'
endef
