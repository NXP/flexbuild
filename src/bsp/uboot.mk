#
# Copyright 2017-2024 NXP
#
# SPDX-License-Identifier: BSD-3-Clause

# build U-Boot image for Layerscape and i.MX platforms

include imx_mkimage.mk


uboot u-boot:
	@if [ "$(MACHINE)" = "imx8mm_phygate-tauri-l" ]; then \
	  # PHYTEC board: use uboot-phytec and PHYTEC repo/tag \
		export UBOOT_DIR=uboot-phytec; \
			# Read PHYTEC U-Boot repo and tag from board config (if present). \
			# If not present, Just print error and exit. \
					  repo=`grep '^PHYTEC_UBOOT_REPO=' $(FBDIR)/configs/board/$(MACHINE).conf 2>/dev/null | tail -n1 | cut -d'"' -f2 2>/dev/null` || repo=""; \
					  if [ -z "$$repo" ]; then \
						  printf '\033[1;31mERROR: PHYTEC_UBOOT_REPO not defined in %s/configs/board/%s.conf\033[0m\n' $(FBDIR) $(MACHINE); \
						  printf 'Please add PHYTEC_UBOOT_REPO="<git://...>" to %s/configs/board/%s.conf\n' $(FBDIR) $(MACHINE); \
						  exit 1; \
					  fi; \
			  export UBOOT_REPO="$$repo"; \
					  tag=`grep '^PHYTEC_UBOOT_TAG=' $(FBDIR)/configs/board/$(MACHINE).conf 2>/dev/null | tail -n1 | cut -d'"' -f2 2>/dev/null` || tag=""; \
					  if [ -z "$$tag" ]; then \
						  printf '\033[1;31mERROR: PHYTEC_UBOOT_TAG not defined in %s/configs/board/%s.conf\033[0m\n' $(FBDIR) $(MACHINE); \
						  printf 'Please add PHYTEC_UBOOT_TAG="<tag>" (e.g. v2022.04_2.2.2-phy5 or tags/v2022.04_2.2.2-phy5) to %s/configs/board/%s.conf\n' $(FBDIR) $(MACHINE); \
						  exit 1; \
					  fi; \
					  case "$$tag" in tags/*) UBOOT_TAG="$$tag" ;; *) UBOOT_TAG="tags/$$tag" ;; esac; \
			  export UBOOT_TAG="$$UBOOT_TAG"; \
	  printf "\033[0;32m(Fetching PHYTEC'S Phygate Tauri-l IMX8MM U-boot)\033[0m\n"; \
		if [ ! -d $(BSPDIR)/$$UBOOT_DIR ]; then \
			git clone --quiet $$UBOOT_REPO $(BSPDIR)/$$UBOOT_DIR >/dev/null 2>&1; \
			if [ "$(MACHINE)" = "imx8mm_phygate-tauri-l" ]; then \
				cd $(BSPDIR)/$$UBOOT_DIR && \
				wget -q https://download.phytec.de/Software/Linux/BSP-Yocto-i.MX8MM/BSP-Yocto-NXP-i.MX8MM-PD23.1.0/images/ampliphy-vendor/phygate-tauri-l-imx8mm-2/imx-boot-tools/bl31-imx8mm.bin && \
				wget -q https://download.phytec.de/Software/Linux/BSP-Yocto-i.MX8MM/BSP-Yocto-NXP-i.MX8MM-PD23.1.0/images/ampliphy-vendor/phygate-tauri-l-imx8mm-2/imx-boot-tools/lpddr4_pmu_train_1d_dmem.bin && \
				wget -q https://download.phytec.de/Software/Linux/BSP-Yocto-i.MX8MM/BSP-Yocto-NXP-i.MX8MM-PD23.1.0/images/ampliphy-vendor/phygate-tauri-l-imx8mm-2/imx-boot-tools/lpddr4_pmu_train_1d_imem.bin && \
				wget -q https://download.phytec.de/Software/Linux/BSP-Yocto-i.MX8MM/BSP-Yocto-NXP-i.MX8MM-PD23.1.0/images/ampliphy-vendor/phygate-tauri-l-imx8mm-2/imx-boot-tools/lpddr4_pmu_train_2d_dmem.bin && \
				wget -q https://download.phytec.de/Software/Linux/BSP-Yocto-i.MX8MM/BSP-Yocto-NXP-i.MX8MM-PD23.1.0/images/ampliphy-vendor/phygate-tauri-l-imx8mm-2/imx-boot-tools/lpddr4_pmu_train_2d_imem.bin && \
				mv -f bl31-imx8mm.bin bl31.bin || true; \
			fi; \
		fi; \
		cd $(BSPDIR)/$$UBOOT_DIR && git fetch --tags --quiet >/dev/null 2>&1 && printf '\033[1;37m(tag: %s)\033[0m\n' "$$UBOOT_TAG" && git checkout --quiet $$UBOOT_TAG >/dev/null 2>&1; \
	  printf '\033[1;37mBuilding uboot for imx8mm_phygate-tauri-l\033[0m\n'; \
	  cd $(BSPDIR)/$$UBOOT_DIR; \
	  if [ -n "$(UBOOT_CONFIG)" ]; then \
	    uboot_cfg="$(UBOOT_CONFIG)"; \
	  else \
	    uboot_cfg=$(MACHINE)_defconfig; \
	  fi; \
		for cfg in $$uboot_cfg; do \
			printf '\033[0;32mconfig = %s\033[0m\n' "$$cfg"; \
			$(MAKE) -C $(BSPDIR)/$$UBOOT_DIR -j$(JOBS) O=$(FBOUTDIR)/bsp/uboot-phytec/$(MACHINE)/output/$$cfg $$cfg $(LOG_MUTE); \
			$(MAKE) -C $(BSPDIR)/$$UBOOT_DIR -j$(JOBS) O=$(FBOUTDIR)/bsp/uboot-phytec/$(MACHINE)/output/$$cfg $(LOG_MUTE); \
		done; \
	printf '\033[0;32m\033[1;32muboot for imx8mm_phygate-tauri-l in $(FBOUTDIR)/bsp/uboot-phytec/imx8mm_phygate-tauri-l  [Done]\033[0m\n'; \
	# After successful U-Boot build, copy flash.bin to images as imx-boot for PHYTEC board only \
	flashbin_path="$(FBOUTDIR)/bsp/uboot-phytec/imx8mm_phygate-tauri-l/output/phycore-imx8mm_defconfig/flash.bin"; \
	if [ -f "$$flashbin_path" ]; then \
		cp "$$flashbin_path" "$(FBOUTDIR)/images/imx-boot"; \
		echo "[INFO] Copied $$flashbin_path to $(FBOUTDIR)/images/imx-boot"; \
	else \
		echo "[WARN] flash.bin not found at $$flashbin_path, imx-boot not copied."; \
	fi; \
	else \
	  # All other boards: use default uboot and repo-mngr logic \
	  $(call repo-mngr,fetch,uboot,bsp) && \
	  curbrch=`cd $(BSPDIR)/uboot && git branch | grep ^* | cut -d' ' -f2` && \
	  $(call fbprint_b,"u-boot $$curbrch for $(MACHINE)") && \
	  cd $(BSPDIR)/uboot; \
	  if [ "$(MACHINE)" != "imx8mm_phygate-tauri-l" ]; then \
	    if [ -d $(FBDIR)/patch/uboot ] && [ ! -f .patchdone ]; then \
	      git am $(FBDIR)/patch/uboot/*.patch && touch .patchdone; \
	    fi; \
	  fi; \
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
	  done; \
	fi



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
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $1 $(LOG_MUTE) && \
	$(MAKE) -C $(BSPDIR)/uboot -j$(JOBS) O=$$opdir $(LOG_MUTE) && \
	if [ $(MACHINE) = imx8mm_phygate-tauri-l ]; then \
		$(MAKE) -C $(BSPDIR)/uboot-phytec -j$(JOBS) O=$$opdir flash.bin; \
	fi && \
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
