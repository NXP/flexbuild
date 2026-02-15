# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_LINUXPTP ?= n

linuxptp:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_LINUXPTP))" != "y" ]; then \
		echo "Skipping linuxptp: CONFIG_APP_LINUXPTP!='y' (current='$(strip $(CONFIG_APP_LINUXPTP))')"; \
		exit 0; \
	fi && \
	$(call download_repo,linuxptp,apps/networking,git) && \
	$(call fbprint_b,"linuxptp") && \
	mkdir -p $(DESTDIR)/etc/ && \
	cd $(NETDIR)/linuxptp && sed -i '282 s/pr_debug/pr_info/g' ts2phc_slave.c && $(MAKE) $(LOG_MUTE) && \
	install -p -m 755 -d $(DESTDIR)/usr/local/sbin && \
	install ptp4l hwstamp_ctl nsm phc2sys phc_ctl pmc timemaster ts2phc $(DESTDIR)/usr/local/sbin && \
	cp -rf $(FBDIR)/configs/extra/ts2phc.cfg $(DESTDIR)/etc/ && \
	cp -rf $(FBDIR)/configs/extra/gps.rc $(DESTDIR)/etc/  && \
	$(call fbprint_d,"linuxptp")
