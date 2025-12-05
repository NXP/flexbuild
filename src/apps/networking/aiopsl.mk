# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
# only used on: lx216, ls1088 and ls2088



aiopsl:
	@[ $(SOCFAMILY) != LS ] && exit || \
	 $(call download_repo,aiopsl,apps/networking) && \
	 $(call patch_apply,aiopsl,apps/networking) && \
	 $(call fbprint_b,"aiopsl") && \
	 cd $(NETDIR)/aiopsl && \
	 mkdir -p $(DESTDIR)/usr/local/aiop/bin && \
	 cp -rf misc/setup/scripts $(DESTDIR)/usr/local/aiop  && \
	 cp -rf misc/setup/traffic_files $(DESTDIR)/usr/local/aiop && \
	 cp -rf demos/images/* $(DESTDIR)/usr/local/aiop/bin && \
	 $(call fbprint_d,"aiopsl")
