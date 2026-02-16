#
# Copyright 2017-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# build U-Boot image for Layerscape and i.MX platforms



UBOOT_CONFIG_CLEAN := $(subst ",,$(UBOOT_CONFIG))
UBOOT_CONFIG_1 := $(word 1,$(UBOOT_CONFIG_CLEAN))
UBOOT_CONFIG_2 := $(word 2,$(UBOOT_CONFIG_CLEAN))

ifeq ($(CONFIG_SECURE_BOOT),y)
    uboot_cfg := $(UBOOT_CONFIG_2)
else
    uboot_cfg := $(UBOOT_CONFIG_1)
endif

.PHONY: uboot u-boot
uboot u-boot:
	@$(call download_repo,uboot,bsp) && \
	$(call patch_apply,uboot,bsp) && \
	if [ "$(CONFIG_SECURE_BOOT)" = y ]; then \
		$(call fbprint_b,"u-boot for $(MACHINE) [secure boot]"); \
	else \
		$(call fbprint_b,"u-boot for $(MACHINE)"); \
	fi && \
	cd $(BSPDIR)/uboot && \
	if [ -z "$(uboot_cfg)" ]; then \
		$(call fbprint_e,"Failed to determine u-boot configuration") && exit 1; \
	fi && \
	\
	export ARCH=arm64 && export CROSS_COMPILE=aarch64-linux-gnu-; \
	opdir=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg) && mkdir -p $$opdir && \
	unset PKG_CONFIG_SYSROOT_DIR && \
	\
	$(call fbprint_n,"config = $(uboot_cfg)") && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $(uboot_cfg) $(LOG_MUTE) && \
	make -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $(LOG_MUTE) && \
	$(call fbprint_d,"u-boot for $(MACHINE) in $(FBOUTDIR)/bsp/u-boot/$(MACHINE)");
