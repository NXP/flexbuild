# SPDX-License-Identifier: BSD-3-Clause
#
# Copyright 2025 NXP
#

#
# $(1)=pkg_name, $(2)=app_dir $(3)=patchpattern
#
define patch_apply
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
		echo "[INFO] Applying patches "; \
		for i in $$(ls "$$patchdir"/$$patchpattern 2>/dev/null); do \
			[ -d "$$i" ] && echo "Ignoring subdirectory '$$i' " $(LOG_MUTE) && continue; \
			echo '' $(LOG_MUTE); \
			echo "Applying $$i  " $(LOG_MUTE); \
			patch -f -p1 -d $$targetdir < "$$i" $(LOG_MUTE); \
		done && \
		touch $$targetdir/.patchdone && \
		echo "[INFO] Applying patches  DONE " $(LOG_MUTE); \
	fi
endef






#
# $(1)=patch_dir, $(2)=target_dir $(3)=patchpattern
#
define patch_apply_simple
	patchpattern=$(or $(3),*.patch) && \
	\
	if [ -d $(1) ] && [ ! -f $(2)/.patchdone  ]; then \
		if [ ! -d "$(2)" ] ; then \
			echo "Aborting.  '$(2)' is not a directory." $(LOG_MUTE); \
			exit 1; \
		fi && \
		\
		echo "[INFO] Applying patches "; \
		for i in $$(ls "$(1)"/$$patchpattern 2>/dev/null); do \
			[ -d "$$i" ] && echo "Ignoring subdirectory '$$i' " $(LOG_MUTE) && continue; \
			echo '' $(LOG_MUTE); \
			echo "Applying $$i  " $(LOG_MUTE); \
			patch -f -p1 -d $(2) < "$$i" $(LOG_MUTE); \
		done && \
		touch $(2)/.patchdone && \
		echo "[INFO] Applying patches  DONE " $(LOG_MUTE); \
	fi
endef
