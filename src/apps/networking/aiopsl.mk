# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



aiopsl:
	@[ $(SOCFAMILY) != LS -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"AIOPSL") && \
	 $(call repo-mngr,fetch,aiopsl,apps/networking) && \
	 cd $(NETDIR)/aiopsl && \
	 mkdir -p $(DESTDIR)/usr/local/aiop/bin && \
	 cp -rf misc/setup/scripts $(DESTDIR)/usr/local/aiop  && \
	 cp -rf misc/setup/traffic_files $(DESTDIR)/usr/local/aiop && \
	 cp -rf demos/images/* $(DESTDIR)/usr/local/aiop/bin && \
	 $(call fbprint_d,"AIOPSL")
