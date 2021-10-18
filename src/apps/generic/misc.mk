# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



misc:
	@$(call fbprint_b,"misc") && \
	 $(CROSS_COMPILE)gcc $(FBDIR)/src/misc/ccsr.c -o $(DESTDIR)/usr/local/bin/ccsr && \
	 $(call fbprint_d,"misc")
