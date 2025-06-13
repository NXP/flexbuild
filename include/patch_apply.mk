# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2025 NXP
#

#
# $(1)=pkg_name, $(2)=app_dir $(3)=patchpattern
#
define patch_apply
	echo "[INFO] Applying patches ..." $(LOG_MUTE); \
	targetdir=$(PKGDIR)/$(2)/$(1) && \
	patchdir=$(FBDIR)/patch/$(1) && \
	patchpattern=$(or $(3),*.patch) && \
	\
	if [ -d $$patchdir ] && [ ! -f $$targetdir/.patchdone  ]; then \
		if [ ! -d "$$targetdir" ] ; then \
			echo "Aborting.  '$$targetdir' is not a directory." $(LOG_MUTE); \
			exit 1; \
		fi && \
		\
		for i in $$(ls "$$patchdir"/$$patchpattern 2>/dev/null); do \
			[ -d "$$i" ] && echo "Ignoring subdirectory '$$i' " $(LOG_MUTE) && continue; \
			echo '' $(LOG_MUTE); \
			echo "Applying $$i ... " $(LOG_MUTE); \
			patch -f -p1 -d $$targetdir < "$$i" $(LOG_MUTE); \
		done && \
		touch $$targetdir/.patchdone && \
		echo "[INFO] Applying patches ... DONE " $(LOG_MUTE); \
	fi
endef
