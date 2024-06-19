# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



misc:
	@[ $(SOCFAMILY) != LS ] && exit || \
	 sudo $(CROSS_COMPILE)gcc $(FBDIR)/src/misc/ccsr.c -o $(RFSDIR)/usr/local/bin/ccsr
