#
# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# build U-Boot image for Layerscape and i.MX platforms

include imx_mkimage.mk


uboot u-boot:
	@$(call repo-mngr,fetch,uboot,bsp) && \
	 curbrch=`cd $(BSPDIR)/uboot && git branch | grep ^* | cut -d' ' -f2` && \
	 $(call fbprint_n,"Building u-boot $$curbrch for $(MACHINE)") && \
	 cd $(BSPDIR)/uboot && \
	 if [ -d $(FBDIR)/patch/uboot ] && [ ! -f .patchdone ]; then \
	     git am $(FBDIR)/patch/uboot/*.patch && touch .patchdone; \
	 fi && \
	 if [ "$(BOOTTYPE)" = tfa -a "$(COT)" = arm-cot-with-verified-boot ]; then \
	     uboot_cfg=$(MACHINE)_tfa_verified_boot_defconfig; \
	 elif [ -n "$(UBOOT_CONFIG)" ]; then \
	     uboot_cfg="$(UBOOT_CONFIG)"; \
	 elif [ "$(BOOTTYPE)" = tfa -a "$(SECURE)" = y ]; then \
	     uboot_cfg=$(MACHINE)_tfa_SECURE_BOOT_defconfig; \
	 elif [ "$(BOOTTYPE)" = tfa ]; then \
	     uboot_cfg=$(MACHINE)_tfa_defconfig; \
	 fi; \
	 for cfg in $$uboot_cfg; do \
	     $(call build-uboot-target,$$cfg) \
	 done



define build-uboot-target
	if echo $1 | grep -qE 'ls1021a|^mx'; then \
	    export ARCH=arm && export CROSS_COMPILE=arm-linux-gnueabihf-; \
	else \
	    export ARCH=arm64 && export CROSS_COMPILE=aarch64-linux-gnu-; \
	fi && \
	if [ $(MACHINE) != all ]; then brd=$(MACHINE); fi && \
	opdir=$(FBOUTDIR)/bsp/u-boot/$$brd/output/$1 && mkdir -p $$opdir && \
	unset PKG_CONFIG_SYSROOT_DIR && \
	\
	$(call fbprint_n,"config = $1") && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $1 && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir && \
	\
	if echo $1 | grep -iqE 'sdcard|nand'; then \
	   [ -f $$opdir/u-boot-with-spl-pbl.bin ] && srcbin=u-boot-with-spl-pbl.bin || srcbin=u-boot-with-spl.bin; \
	   if echo $1 | grep -iqE 'SECURE_BOOT'; then \
		if echo $1 | grep -iqE 'sdcard'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBOUTDIR)/bsp/u-boot/$$brd/uboot_$${brd}_sdcard_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBOUTDIR)/bsp/u-boot/$$brd/uboot_$${brd}_sdcard_dtb.bin ; \
		elif echo $1 | grep -iqE 'nand'; then \
		   cp $$opdir/spl/u-boot-spl.bin $(FBOUTDIR)/bsp/u-boot/$$brd/uboot_$${brd}_nand_spl.bin ; \
		   cp $$opdir/u-boot-dtb.bin $(FBOUTDIR)/bsp/u-boot/$$brd/uboot_$${brd}_nand_dtb.bin ; \
		fi; \
	   fi; \
	   tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	elif echo $1 | grep -iqE 'verified_boot'; then \
	    mkdir -p $(FBOUTDIR)/bsp/atf/$$brd; \
	    cat $$opdir/u-boot-nodtb.bin $$opdir/u-boot.dtb > $$opdir/u-boot-combined-dtb.bin; \
	    cp -f $$opdir/u-boot-nodtb.bin $$opdir/u-boot.dtb $$opdir/u-boot-combined-dtb.bin $(FBOUTDIR)/bsp/atf/$$brd/; \
	    cp -f $$opdir/u-boot.dtb $$opdir/tools/mkimage $(BSPDIR)/atf/; \
	    srcbin=u-boot-combined-dtb.bin; \
	else \
	    srcbin=u-boot.bin; \
	    tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
	fi;  \
	\
	if echo $1 | grep -q ^ls1021a && [ ! -d $(FBOUTDIR)/bsp/rcw/$(MACHINE) ]; then \
	    bld rcw -m $(MACHINE); \
	fi && \
	if echo $1 | grep -qE '^imx8|^imx9'; then \
	    bld atf -m $(MACHINE) -b sd && \
	    $(call imx_mkimage_target, $1) \
	elif echo $1 | grep -qiE "mx6|mx7"; then \
	    cp $$opdir/u-boot-dtb.imx $(FBOUTDIR)/bsp/u-boot/$$brd/; \
	else \
	    cp $$opdir/$$srcbin $(FBOUTDIR)/bsp/u-boot/$$brd/$$tgtbin ; \
	fi && \
	$(call fbprint_d,"u-boot for $$brd in $(FBOUTDIR)/bsp/u-boot/$$brd");
endef
