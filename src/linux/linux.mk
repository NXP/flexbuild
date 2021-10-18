#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#


UEFI_DTB_LIST = freescale/fsl-ls1043a-rdb-sdk.dtb freescale/fsl-ls1046a-rdb-sdk.dtb freescale/fsl-ls2088a-rdb.dtb freescale/fsl-lx2160a-rdb.dtb


linux:
ifeq ($(CONFIG_LINUX), "y")
	@$(call repo-mngr,fetch,linux,linux) && \
	cd $(PKGDIR)/linux && \
	curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	$(call fbprint_n,"Building $(KERNEL_TREE) with $$curbrch") && \
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
	opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir/tmp && \
	if [ "$(BUILDARG)" = "custom" ]; then \
	    $(MAKE) menuconfig -C $(KERNEL_PATH) O=$$opdir && \
	    $(call fbprint_d,"Custom kernel config: $$opdir/.config") && \
	    $(call fbprint_n,"Then rerun the command with removing \'custom\' to proceed with the customized .config") && exit; \
	fi; \
	$(call fbprint_n,"Total Config List = $(KERNEL_CFG) $(FRAGMENT_CFG)") && \
	if [ ! -f $$opdir/.config ]; then $(MAKE) $(KERNEL_CFG) $(FRAGMENT_CFG) -C $(KERNEL_PATH) O=$$opdir 1>/dev/null; fi && \
	if [ "$(ENDIANTYPE)" = "be" ]; then \
	    sed -i 's/# CONFIG_CPU_BIG_ENDIAN is not set/CONFIG_CPU_BIG_ENDIAN=y/' $$opdir/.config; \
	    echo Big-Endian enabled!; \
	fi && \
	$(MAKE) -j$(JOBS) all -C $(KERNEL_PATH) O=$$opdir && \
        if [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = LS ]; then \
            $(MAKE) $$extflags $(UEFI_DTB_LIST) -C $(KERNEL_PATH) O=$$opdir; \
        fi && \
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
	rm -rf $$opdir/tmp && \
        $(MAKE) -j$(JOBS) modules -C $(KERNEL_PATH) O=$$opdir && \
        $(MAKE) -j$(JOBS) modules_install INSTALL_MOD_PATH=$$opdir/tmp -C $(KERNEL_PATH) O=$$opdir && \
	ls $$opdir/arch/$$locarch/boot/dts/$$dtbstr | xargs -I {} cp {} $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	ls -l $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	$(call fbprint_d,"$(KERNEL_TREE) $$curbrch in $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)")
endif



linux-deb: linux
	@cd $(PKGDIR)/linux && \
	 opdir=$(KERNEL_OUTPUT_PATH)/`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	 $(MAKE) -j$(JOBS) headers_install INSTALL_HDR_PATH=$$opdir/tmp -C $(KERNEL_PATH) O=$$opdir && \
	 $(MAKE) -j$(JOBS) bindeb-pkg -C $(KERNEL_PATH) O=$$opdir
