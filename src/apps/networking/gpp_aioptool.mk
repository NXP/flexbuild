# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# only used on: lx2 and ls2088a



gpp_aioptool:
	@[ $(SOCFAMILY) != LS ] && exit || \
	 $(call download_repo,gpp_aioptool,apps/networking) && \
	 $(call patch_apply,gpp_aioptool,apps/networking) && \
	 $(call fbprint_b,"gpp_aioptool") && \
	 cd $(NETDIR)/gpp_aioptool && \
	 sed -i '/libio.h/d' flib/mc/fsl_mc_sys.h && \
	 sed -i 's/= -Wall/= -fcommon -Wall/' Makefile && \
	 $(MAKE) clean $(LOG_MUTE) && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 $(MAKE) install $(LOG_MUTE) && \
	 $(call fbprint_d,"gpp_aioptool")
