# Copyright 2025 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


#
# Provide complete country/region band rules, enabling the system to correctly
# identify the legality of 5GHz channels under the US regulatory domain.
#


wireless_regdb:
	@[ $(SOCFAMILY) != IMX ] && exit || \
	$(call dl_by_wget,wireless_regdb_tar,wireless_regdb.tar.xz) && \
	echo "Extracting wireless_regdb" && \
	if [ ! -d "$(UTILSDIR)"/wireless_regdb ]; then \
		mkdir -p "$(UTILSDIR)"/wireless_regdb; \
		tar -xf $(FBDIR)/dl/wireless_regdb.tar.xz --strip-components=1 --wildcards -C $(UTILSDIR)/wireless_regdb; \
	fi && \
	mkdir -p $(DESTDIR)/lib/firmware && \
	cd "$(UTILSDIR)"/wireless_regdb && \
	rm -f $1/firmware/regulatory.* && \
	cp -Prf regulatory.* $(DESTDIR)/lib/firmware && \
	$(call fbprint_d,"wireless_regdb")
