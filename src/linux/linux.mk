#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
################################################################################
# FLEXBUILD – EXTENDED LINUX DISPATCHER (NEW)
################################################################################

# Main linux dispatcher
linux:
ifeq ($(MACHINE),imx8mm_phygate-tauri-l)
	$(MAKE) linux-phytec
else
	$(MAKE) linux-nxp-default
endif

# PHYTEC kernel fragments (if any) from board config — done at parse time
## PHYTEC_KERNEL_FRAGMENTS is computed inside the recipe using shell to ensure FBDIR is present






################################################################################
# ORIGINAL NXP LINUX + BUILD
################################################################################

linux-nxp-default:
	@$(call repo-mngr,fetch,linux,linux) && \
	$(MAKE) linux-core KERNEL_PATH="$(KERNEL_PATH)" KERNEL_TREE="$(KERNEL_TREE)"


################################################################################
# PHYTEC LINUX KERNEL FETCH AND BUILD
################################################################################

linux-phytec:
	@if [ -z "$$FBDIR" -o ! -d "$$FBDIR" ]; then export FBDIR=$$(pwd); fi; \
	phy_conf="$$FBDIR/configs/board/$(MACHINE).conf"; \
	echo "DEBUG: phy_conf path: $$phy_conf"; \
	if [ ! -f "$$phy_conf" ]; then echo "ERROR: Board config file not found: $$phy_conf"; exit 1; fi; \
	echo "DEBUG: [$(date)] Before extracting KERNEL_REPO"; \
	KERNEL_REPO=$$(grep '^PHYTEC_LINUX_REPO=' $$phy_conf | cut -d'"' -f2); \
	echo "DEBUG: [$(date)] After extracting KERNEL_REPO: $$KERNEL_REPO"; \
	echo "DEBUG: [$(date)] Before extracting KERNEL_TAG"; \
	KERNEL_TAG=$$(grep '^PHYTEC_LINUX_TAG=' $$phy_conf | cut -d'"' -f2); \
	echo "DEBUG: [$(date)] After extracting KERNEL_TAG: $$KERNEL_TAG"; \
	echo "DEBUG: [$(date)] Before extracting KERNEL_FRAGMENTS"; \
	KERNEL_FRAGMENTS=$$(awk -F'\"' '/^KERNEL_FRAGMENTS=/{print $$2; exit}' "$$phy_conf"); \
	echo "DEBUG: [$(date)] After extracting KERNEL_FRAGMENTS: $$KERNEL_FRAGMENTS"; \
	FRAGMENT_CFG="$$KERNEL_FRAGMENTS"; \
	if [ -z "$$KERNEL_REPO" ] || [ -z "$$KERNEL_TAG" ]; then \
		echo "ERROR: Missing PHYTEC Linux configuration in $$phy_conf"; exit 1; \
	fi; \
	KERNEL_TREE=linux-phytec; \
	KDIR="$(FBDIR)/components_lsdk2506/linux/linux-phytec"; \
	KERNEL_PATH="$(FBDIR)/components_lsdk2506/linux/linux-phytec"; \
	$(call fbprint_n,Fetching PHYTEC Linux for $(MACHINE)); \
	$(call fbprint_n,Using KERNEL_CFG=$$KERNEL_CFG FRAGMENT_CFG=$$FRAGMENT_CFG); \
	$(call fbprint_n,Building linux for $(MACHINE)); \
	echo "DEBUG: [$(date)] Before mkdir -p $(FBDIR)/components_lsdk2506/linux"; \
	mkdir -p $(FBDIR)/components_lsdk2506/linux; \
	echo "DEBUG: [$(date)] Before .git directory check for $$KDIR/.git"; \
	if [ ! -d "$$KDIR/.git" ]; then \
		echo "DEBUG: [$(date)] About to clone PHYTEC kernel repo: $$KERNEL_REPO into $$KDIR"; \
		echo "DEBUG: [$(date)] Running: git clone $$KERNEL_REPO $$KDIR"; \
		time git clone $$KERNEL_REPO $$KDIR; status=$$?; \
		echo "DEBUG: [$(date)] git clone exited with status $$status"; \
		if [ $$status -eq 0 ]; then \
			echo "DEBUG: [$(date)] git clone completed successfully."; \
		else \
			echo "ERROR: [$(date)] git clone failed with status $$status!"; exit 1; \
		fi; \
	else \
		echo "DEBUG: PHYTEC kernel repo already cloned at $$KDIR"; \
	fi; \
	mkdir -p $(FBDIR)/build_lsdk2506/linux/linux-phytec; \
    cd $$KDIR && git fetch --tags >/dev/null 2>&1 && git checkout $$KERNEL_TAG >/dev/null 2>&1; \
	# Show PHYTEC kernel tag that was checked out
	echo "(tag: $$KERNEL_TAG)"; \
	$(call fbprint_n,Building linux with $$KERNEL_TAG ...); \
	$(call fbprint_n,linux for $(MACHINE) in $$KDIR [Ready]); \
	echo "DEBUG: [linux-phytec] KDIR=\"$(FBDIR)/components_lsdk2506/linux/linux-phytec\""; \
	echo "DEBUG: [linux-phytec] KERNEL_PATH=\"$(FBDIR)/components_lsdk2506/linux/linux-phytec\""; \
	echo "DEBUG: [linux-phytec] KERNEL_TREE=\"linux-phytec\""; \
	echo "DEBUG: [linux-phytec] KERNEL_CFG=\"$(KERNEL_CFG)\""; \
	echo "DEBUG: [linux-phytec] FRAGMENT_CFG=\"$$FRAGMENT_CFG\""; \
	export KERNEL_PATH="$(FBDIR)/components_lsdk2506/linux/linux-phytec"; \
	export KERNEL_TREE="linux-phytec"; \
	export KERNEL_CFG="$(KERNEL_CFG)"; \
	export FRAGMENT_CFG="$$FRAGMENT_CFG"; \
	export KERNEL_OUTPUT_PATH="$(FBOUTDIR)/linux/linux-phytec/$(DESTARCH)/$(SOCFAMILY)/output"; \
	$(MAKE) linux-core KERNEL_PATH="$(FBDIR)/components_lsdk2506/linux/linux-phytec" KERNEL_TREE="linux-phytec" KERNEL_CFG="$(KERNEL_CFG)" FRAGMENT_CFG="$$FRAGMENT_CFG" KERNEL_OUTPUT_PATH="$(FBOUTDIR)/linux/linux-phytec/$(DESTARCH)/$(SOCFAMILY)/output"
	ln -sf linux-phytec $(FBDIR)/build_lsdk2506/linux/kernel-phytec; 
	rm -f $(FBDIR)/build_lsdk2506/linux/linux-phytec/linux-phytec; 
	$(MAKE) linux-core KERNEL_PATH="$(FBDIR)/components_lsdk2506/linux/linux-phytec" KERNEL_TREE="linux-phytec" KERNEL_CFG="$(KERNEL_CFG)" FRAGMENT_CFG="$$FRAGMENT_CFG" KERNEL_OUTPUT_PATH="$(FBOUTDIR)/linux/linux-phytec/$(DESTARCH)/$(SOCFAMILY)/output"

linux-core:
	cd $(KERNEL_PATH) && \
	if [ "$(KERNEL_TREE)" = "linux-phytec" ]; then \
		conf="$(FBDIR)/configs/board/$(MACHINE).conf"; \
		if [ -f "$$conf" ]; then \
			KERNEL_FRAGMENTS=$$(awk -F'\"' '/^KERNEL_FRAGMENTS=/{print $$2; exit}' "$$conf"); \
			FRAGMENT_CFG="$$KERNEL_FRAGMENTS"; \
			echo "DEBUG: [linux-core] FRAGMENT_CFG from conf='$$FRAGMENT_CFG'"; \
		fi; \
	fi && \
		    curbrch=$$(git symbolic-ref --short -q HEAD 2>/dev/null || git describe --tags --always 2>/dev/null) && \
		    curbrch=$$(echo "$$curbrch" | sed 's/[^A-Za-z0-9._-]/_/g') && \
		    if [ "$$curbrch" = "HEAD" -a "$(KERNEL_TREE)" != "linux-phytec" ]; then \
			    $(call fbprint_w,"Please set proper tag/branch name in kernel repo $(KERNEL_PATH)") && exit 1; \
		    fi && \
	if [ "$(MACHINE)" != "imx8mm_phygate-tauri-l" ]; then \
		if [ -d $(FBDIR)/patch/linux ] && [ ! -f .patchdone ]; then \
			git am $(FBDIR)/patch/linux/*.patch && touch .patchdone; \
		fi; \
	fi && \
	if [ "$(KERNEL_TREE)" = "linux-phytec" ]; then \
		$(call fbprint_b,"$(KERNEL_TREE) with $$curbrch") && \
		$(call fbprint_n,"Compiler = `$(CROSS_COMPILE)gcc --version | head -1`"); \
	else \
	echo -e "\033[0;32m$(KERNEL_TREE) with $$curbrch\033[0m" && \
	echo -e "\033[0;32mCompiler = `$(CROSS_COMPILE)gcc --version | head -1`\033[0m"; \
	fi && \
	if [ "$(MACHINE)" = "imx8mm_phygate-tauri-l" ]; then \
		locarch=arm64; dtbstr=freescale/imx8mm-phygate-tauri.dtb; \
	elif [ $(DESTARCH) = arm64 -a $(SOCFAMILY) = IMX ]; then \
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
	    $(call fbprint_n,"Run 'bld linux' to proceed with the customized .config above") && exit; \
	fi; \
	if [ "$(KERNEL_TREE)" = "linux-phytec" ]; then \
		$(call fbprint_n,"Total Config List = $(KERNEL_CFG) $$FRAGMENT_CFG"); \
	else \
	echo -e "\033[0;32mTotal Config List = $(KERNEL_CFG) $(FRAGMENT_CFG)\033[0m"; \
	fi && \
	if [ ! -f $$opdir/.config ]; then \
		if [ "$(KERNEL_TREE)" = "linux-phytec" ]; then \
			echo "DEBUG: generating config: make $(KERNEL_CFG) $$FRAGMENT_CFG -C $(KERNEL_PATH) O=$$opdir"; \
		fi && \
		$(MAKE) $(KERNEL_CFG) $$FRAGMENT_CFG -C $(KERNEL_PATH) O=$$opdir 1>/dev/null 2>&1; \
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
	$(MAKE) -j$(JOBS) modules_install INSTALL_MOD_PATH=$$opdir/tmp -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	ls $$opdir/arch/$$locarch/boot/dts/$$dtbstr | xargs -I {} cp {} $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	if [ $(MACHINE) = imx8mm_phygate-tauri-l ]; then \
		cp $(KERNEL_OUTPUT_PATH)/$$curbrch/arch/arm64/boot/dts/freescale/imx8mm-phygate-tauri.dtb \
			$(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/oftree; \
		rm -f $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)/imx8mm-phygate-tauri.dtb; \
		mkdir -p $(KERNEL_OUTPUT_PATH)/$$curbrch; \
		cp -r $(KERNEL_PATH)/* $(KERNEL_OUTPUT_PATH)/$$curbrch; \
		ls -l $$opdir; \
	fi && \
	ls -l $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) && \
	if [ "$(KERNEL_TREE)" = "linux-phytec" ]; then \
		$(call fbprint_d,"$(KERNEL_TREE) $$curbrch in $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY)") ; \
	else \
		echo -e "\033[1;32m$(KERNEL_TREE) $$curbrch in $(FBOUTDIR)/linux/$(KERNEL_TREE)/$(DESTARCH)/$(SOCFAMILY) [Done]\033[0m"; \
	fi


################################################################################
# EXTRA TARGETS
################################################################################

ifeq ($(MACHINE),imx8mm_phygate-tauri-l)
linux-modules:
	$(call fbprint_d,"linux-modules")
else
linux-modules: nxp_wlan_bt cryptodev_linux mdio_proxy_module isp_vvcam_module
	$(call fbprint_d,"linux-modules")
endif

linux-headers:
	@$(call repo-mngr,fetch,linux,linux) && \
	cd $(PKGDIR)/linux && \
	curbrch=`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	opdir=$(KERNEL_OUTPUT_PATH)/$$curbrch && mkdir -p $$opdir/tmp && \
	mkdir -p $(DESTDIR)/usr && \
	$(MAKE) -j$(JOBS) headers_install INSTALL_HDR_PATH=$(DESTDIR)/usr -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	$(call fbprint_d,"linux-headers")

linux-deb:
	@opdir=$(KERNEL_OUTPUT_PATH)/`cd $(KERNEL_PATH) && git branch | grep ^* | cut -d' ' -f2` && \
	$(MAKE) -j$(JOBS) bindeb-pkg -C $(KERNEL_PATH) O=$$opdir $(LOG_MUTE) && \
	$(call fbprint_d,"linux-deb")
