#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause



linux:
	$(call download_repo,linux,linux) && \
	$(call patch_apply,linux,linux) && \
	cd $(KERNEL_PATH) && \
	$(call fbprint_b,"$(KERNEL_TREE) with $(KERNEL_BRANCH)") && \
	$(call fbprint_n,"Compiler = `$(CROSS_COMPILE)gcc --version | head -1`") && \
	if [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = IMX ]; then \
	    locarch=arm64; dtbstr=freescale/imx*.dtb; \
	elif [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = LS ]; then \
	    locarch=arm64; dtbstr=freescale/fsl*.dtb; extflags="DTC_FLAGS='-@'"; \
	elif [ $(DESTARCH) = arm32 -a $(SOCFAMILY) = LS ]; then \
	    locarch=arm; dtbstr=ls*.dtb; \
	elif [ $(DESTARCH) = arm32 -a $(SOCFAMILY) = IMX ]; then \
	    locarch=arm; dtbstr=imx*.dtb; \
	fi && \
	opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && mkdir -p $$opdir/tmp && \
	if [ "$(BUILDARG)" = "custom" ]; then \
	    $(MAKE) menuconfig -C $(KERNEL_PATH) O=$$opdir && \
	    $(call fbprint_d,"Custom kernel config: $$opdir/.config") && \
	    $(call fbprint_n,"Run 'bld linux' to proceed with the customized .config above") && exit; \
	fi; \
	$(call fbprint_n,"Total Config List = $(KERNEL_CFG) $(FRAGMENT_CFG)") && \
	if [ ! -f $$opdir/.config ]; then \
	    $(MAKE) $(KERNEL_CFG) $(FRAGMENT_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null 2>&1; \
	fi && \
	if [ "$(ENDIANTYPE)" = "be" ]; then \
	    sed -i 's/# CONFIG_CPU_BIG_ENDIAN is not set/CONFIG_CPU_BIG_ENDIAN=y/' $$opdir/.config; \
	    echo Big-Endian enabled!; \
	fi && \
	$(MAKE) -j$(JOBS) all -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	if [ $(DESTARCH) = arm32 ]; then \
	    $(MAKE) -j$(JOBS) uImage LOADADDR=80008000 -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
	if [ $(DESTARCH) = arm32 -o $(DESTARCH) = arm64 ]; then \
	    $(MAKE) zinstall \
	    INSTALL_PATH=$(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) -C $(KERNEL_PATH) O=$$opdir; \
	fi && \
	if [ $(DESTARCH) = arm64 ]; then \
	    cp $$opdir/arch/$$locarch/boot/Image* $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY); \
	elif [ $(DESTARCH) = arm32 ]; then \
	    cp -f $$opdir/arch/$$locarch/boot/uImage $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY); \
	    cp -f $$opdir/arch/$$locarch/boot/zImage $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY); \
	fi && \
	$(MAKE) -j$(JOBS) modules -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	$(MAKE) -j$(JOBS)  modules_install INSTALL_MOD_PATH=$$opdir/tmp -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	ls $$opdir/arch/$$locarch/boot/dts/$$dtbstr | xargs -I {} cp {} $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	ls -l $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) $(LOG_MUTE) && \
	$(call fbprint_d,"$(KERNEL_TREE) $(KERNEL_BRANCH) in $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)")




linux-modules: cryptodev_linux mdio_proxy_module isp_vvcam_module nxp_wlan_bt
	 $(call fbprint_d,"linux-modules")



linux-headers:
	@$(call download_repo,linux,linux) && \
	 cd $(PKGDIR)/linux && \
	 opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && mkdir -p $$opdir/tmp && \
	 mkdir -p $(DESTDIR)/usr && \
	 $(MAKE) -j$(JOBS) headers_install INSTALL_HDR_PATH=$(DESTDIR)/usr -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	 $(call fbprint_d,"linux-headers")



linux-deb: linux
	opdir=$(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH) && \
	$(MAKE) -j$(JOBS) bindeb-pkg -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	$(call fbprint_d,"linux-deb")
