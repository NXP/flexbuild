# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



gpp_aioptool:
	@[ $(DESTARCH) != arm64 -o $(SOCFAMILY) != LS -o \
	   $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"gpp_aioptool") && \
	 $(call repo-mngr,fetch,gpp_aioptool,apps/networking) && \
	 cd $(NETDIR)/gpp_aioptool && \
	 sed -i '/libio.h/d' flib/mc/fsl_mc_sys.h && \
	 sed -i 's/= -Wall/= -fcommon -Wall/' Makefile && \
	 $(MAKE) clean && \
	 $(MAKE) -j$(JOBS) && \
	 $(MAKE) install && \
	 $(call fbprint_d,"gpp_aioptool")
