# Copyright 2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# Shell Script Automated Tester (unit testing executable files)

ssat:
	@[ $(SOCFAMILY) != IMX -o $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base ] && exit || \
	 $(call fbprint_b,"ssat") && \
	 $(call repo-mngr,fetch,ssat,apps/ml) && \
	 cd $(MLDIR)/ssat && \
	 install -p -m 0755 ssat.sh $(DESTDIR)/usr/bin/ && \
	 install -p -m 0644 ssat-api.sh $(DESTDIR)/usr/bin/ && \
	 ln -sf ssat.sh $(DESTDIR)/usr/bin/ssat && \
	 $(call fbprint_d,"ssat")
