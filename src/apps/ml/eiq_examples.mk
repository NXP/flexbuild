# Copyright 2022-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The eiq examples based on tf-lite on imx93evk

# RDEPENDS: python3 python3-numpy python3-pillow python3-requests python3-opencv tensorflow-lite


eiq_examples:
	@[ $(SOCFAMILY) != IMX  ] && exit || \
	 $(call download_repo,eiq_examples,apps/ml) && \
	 $(call patch_apply,eiq_examples,apps/ml) && \
	 $(call fbprint_b,"eiq_examples") && \
	 cd $(MLDIR)/eiq_examples && \
	 install -d $(DESTDIR)/usr/bin/eiq-examples && \
	 cp -rfa * $(DESTDIR)/usr/bin/eiq-examples && \
	 $(call fbprint_d,"eiq_examples")
