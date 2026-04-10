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
	UBOOT_SECOPT := [secure boot]
else
    uboot_cfg := $(UBOOT_CONFIG_1)
	UBOOT_SECOPT :=
endif


.PHONY: uboot u-boot dl-uboot
dl-uboot:
	@$(call download_repo,uboot,bsp)
	$(call patch_apply,uboot,bsp)
	$(call FB_OUT,u-boot source: $(PKGDIR)/bsp/uboot)

uboot u-boot:
	@$(MAKE) dl-uboot
	$(call fbprint_b,"u-boot for $(MACHINE) $(UBOOT_SECOPT)")
	[ -n "$(uboot_cfg)" ] || { $(call fbprint_e,"Failed to determine u-boot configuration"); exit 1; }
	opdir=$(FBOUTDIR)/bsp/u-boot/$(MACHINE)/output/$(uboot_cfg)
	mkdir -p "$$opdir" || exit 1
	unset PKG_CONFIG_SYSROOT_DIR
	$(call fbprint_n,"config = $(uboot_cfg)")
	$(MAKE) -C $(BSPDIR)/uboot O="$$opdir" $(uboot_cfg) $(LOG_MUTE)
	$(MAKE) -C $(BSPDIR)/uboot O="$$opdir" $(LOG_MUTE)
	$(call fbprint_d,"u-boot for $(MACHINE) in $(FBOUTDIR)/bsp/u-boot/$(MACHINE)")
