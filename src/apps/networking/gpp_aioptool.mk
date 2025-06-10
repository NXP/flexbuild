# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



gpp_aioptool:
	@[ $${MACHINE:0:3} != lx2 -a $${MACHINE:0:6} != ls2088 ] && exit || \
	 $(call fbprint_b,"gpp_aioptool") && \
	 $(call repo-mngr,fetch,gpp_aioptool,apps/networking) && \
	 cd $(NETDIR)/gpp_aioptool && \
	 sed -i '/libio.h/d' flib/mc/fsl_mc_sys.h && \
	 sed -i 's/= -Wall/= -fcommon -Wall/' Makefile && \
	 $(MAKE) clean $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"gpp_aioptool")
