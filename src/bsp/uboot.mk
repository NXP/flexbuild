#
# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# build U-Boot image for Layerscape and i.MX platforms

include $(FBDIR)/src/bsp/imx_mkimage.mk


uboot u-boot:
	 $(call download_repo,uboot,bsp) && \
	 $(call patch_apply,uboot,bsp) && \
     if [ "$(MACHINE)" = all ]; then \
        $(call fbprint_w,"Please specify '-m <machine>'") && exit 0; \
     fi && \
	 $(call fbprint_b,"u-boot for $(MACHINE)") && \
	 cd $(BSPDIR)/uboot && \
	 if [ -n "$(UBOOT_CONFIG)" ]; then \
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
	opdir=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$1 && mkdir -p $$opdir && \
	unset PKG_CONFIG_SYSROOT_DIR && \
	\
	$(call fbprint_n,"config = $1") && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $1 $(LOG_MUTE) && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $(LOG_MUTE) && \
	\
	case "$1" in \
		imx95*) \
			if [ ! -d /usr/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin ]; then \
				bld host-dep -m "$(MACHINE)"; \
			fi; \
			bld imx_sm -m "$(MACHINE)"; \
			bld imx_oei -m "$(MACHINE)"; \
			bld atf -m "$(MACHINE)" -b sd; \
			$(call imx_mkimage_target, "$1") \
			;; \
		imx8*|imx91*|imx93*) \
			bld atf -m "$(MACHINE)" -b sd; \
			$(call imx_mkimage_target, "$1") \
			;; \
		*mx6*|*mx7*) \
			cp "$$opdir/u-boot-dtb.imx" "$$FBOUTDIR/bsp/u-boot/$(MACHINE)/"; \
			;; \
		l*) \
			tgtbin=uboot_`echo $1|sed -r 's/(.*)(_.*)/\1/'`.bin; \
			cp "$$opdir/u-boot.bin" "$$FBOUTDIR/bsp/u-boot/$(MACHINE)/$$tgtbin"; \
			;; \
	esac && \
	$(call fbprint_d,"u-boot for $(MACHINE) in $(FBOUTDIR)/bsp/u-boot/$(MACHINE)");
endef
