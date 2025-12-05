# Copyright 2021-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


# Alsa scenario state files to restore sound state at system boot and save it at system shut down


alsa_state:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call fbprint_b,"alsa_state") && \
	 install -d $(DESTDIR)/var/lib/alsa && \
	 install -m 0644 $(FBDIR)/src/system/alsa_state/asound.state $(DESTDIR)/var/lib/alsa && \
	 install -m 0644 $(FBDIR)/src/system/alsa_state/asound.conf $(DESTDIR)/etc && \
	 $(call fbprint_d,"alsa_state")
