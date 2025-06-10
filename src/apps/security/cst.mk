# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



cst:
	@[ $(DISTROVARIANT) = tiny -o $(DISTROVARIANT) = base -o $(SOCFAMILY) != LS ] && exit || \
	 $(call fbprint_b,"CST") && \
	 $(call repo-mngr,fetch,cst,apps/security) && \
	 cd $(SECDIR)/cst && \
	 sed -i 's/^struct input_field/extern struct input_field/g' tools/*/*.c && \
	 sed -i 's/-g -Wall/-g -Wno-deprecated-declarations -Wall/' Makefile && \
	 $(MAKE) -j$(JOBS) $(LOG_MUTE) && \
	 if [ -n "$(SECURE_PRI_KEY)" ]; then \
	     echo Using specified $(SECURE_PRI_KEY) and $(SECURE_PUB_KEY) ... $(LOG_MUTE) ; \
	     cp -f $(SECURE_PRI_KEY) $(SECDIR)/cst/srk.pri; \
	     cp -f $(SECURE_PUB_KEY) $(SECDIR)/cst/srk.pub; \
	 elif [ ! -f srk.pri -o ! -f srk.pub ]; then \
	     ./gen_keys 1024 $(LOG_MUTE) && echo "Generated new keys!" $(LOG_MUTE); \
	 else \
	     echo "Using default keys srk.pri and srk.pub"; \
	 fi && \
	 $(call fbprint_d,"CST")
