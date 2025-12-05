# Copyright 2023-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# The firmware of Cortex-M33 for Arm Ethos-U NPU on imx93

# COMPATIBLE_MACHINE: imx93

# RDEPEND: python3-flatbuffers python3-numpy python3-lxml

PYTHON_SITEPACKAGES_DIR = "/usr/lib/python3/dist-packages"


ethosu_vela:
	@[ $${MACHINE:0:5} != imx93  ] && exit || \
	 $(call download_repo,ethosu_vela,apps/ml) && \
	 $(call patch_apply,ethosu_vela,apps/ml) && \
	 $(call fbprint_b,"ethosu_vela") && \
	 cd $(MLDIR)/ethosu_vela && \
	 export CC="$(CROSS_COMPILE)gcc --sysroot=$(RFSDIR) -I$(RFSDIR)/usr/include/python3.13" && \
	 export LDFLAGS="-L$(DESTDIR)/usr/lib -L$(RFSDIR)/usr/lib/aarch64-linux-gnu" && \
	 mkdir -p $(MLDIR)/ethosu_vela/build/dist && \
	 NO_FETCH_BUILD=1 ARCH=arm64 \
	 STAGING_INCDIR=$(RFSDIR)/usr/include \
	 STAGING_LIBDIR=$(RFSDIR)/usr/lib/aarch64-linux-gnu \
	 python3 setup.py bdist_wheel --verbose --dist-dir build/dist $(LOG_MUTE) && \
	 pip3 install --ignore-installed --disable-pip-version-check -t $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR) \
	      --no-cache-dir --no-deps build/dist/ethos_u_vela*.whl $(LOG_MUTE) && \
	 cp -rfa build/lib.linux-*cpython*/ethosu $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR) && \
	 rename -f "s/x86_64/aarch64/" $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/ethosu/*.so && \
	 rm -rf $(DESTDIR)/data && \
	 if [ -f $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin/vela ]; then \
	     mv $(DESTDIR)/$(PYTHON_SITEPACKAGES_DIR)/bin/vela $(DESTDIR)/usr/bin/; \
	 fi && \
	 $(call fbprint_d,"ethosu_vela")
