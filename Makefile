# Flexbuild Kconfig-based Build System
# This Makefile integrates Kconfig configuration with flexbuild

SHELL=/bin/bash
#.SHELLFLAGS := -ex -o pipefail -c

DISTRIB_VERSION := lsdk2606
DEFAULT_REPO_TAG := lf-6.12.49-2.2.0
FBDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SCRIPTS_DIR := $(FBDIR)/scripts
BLD := $(FBDIR)/tools/flex-builder
bld := $(FBDIR)/tools/flex-builder
PYTHON := python3
DISTRO_SVR_URL := http://sun.ap.freescale.net/images/debian
#DISTRO_SVR_URL := https://www.nxp.com/lgfiles/sdk
DESTARCH := arm64
DISTRIB_NAME := NXP Debian Linux SDK
RELEASE_TYPE := external
DEFAULT_OUT_PATH := $(FBDIR)/build_${DISTRIB_VERSION}
DEFAULT_PKGDIR := $(FBDIR)/components_${DISTRIB_VERSION}
DEBIAN_CODENAME := trixie
DEBIAN_VERSION :=  13
MC_FW_VERSION := "10.39.0"

LOG_LEVEL ?= 2

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m # No Color

NO_CONFIG_TARGETS := menuconfig defconfig help host-dep docker
ifneq ($(filter $(NO_CONFIG_TARGETS),$(MAKECMDGOALS)),$(MAKECMDGOALS))
ifeq ("$(wildcard $(FBDIR)/.config)","")
$(info )
$(info =====================================================)
$(info .config not found. Please run 'make menuconfig' first)
$(info =====================================================)
$(info )
$(error Build stopped due to missing .config)
endif
endif

export PATH := $(FBDIR):$(FBDIR)/tools:$(PATH)
export GIT_SSL_NO_VERIFY := 1

#ifeq ($(shell [ ! -L tools/bld ] && echo "true"),true)
#  $(shell ln -sf flex-builder tools/bld)
#endif

# Load configuration
-include $(FBDIR)/.config

#IMX_SOC_LIST := imx91evk imx91frdm imx91sfrdm imx93evk imx93frdm imx95evk imx95frdm imx8mpevk imx8mpfrdm imx8mmevk imx8qmmek
#LS_SOC_LIST := ls1028ardb ls1043ardb ls1046ardb lx2160ardb

SOC_FILES := $(wildcard $(FBDIR)/configs/board/*.conf)
SOC_LISTS := $(basename $(notdir $(SOC_FILES)))
IMX_SOC_LIST := $(filter imx%,$(SOC_LISTS))
LS_SOC_LIST := $(filter ls% lx%,$(SOC_LISTS))
SOC_LIST := $(IMX_SOC_LIST) $(LS_SOC_LIST)

ifeq ($(CONFIG_PLATFORM_IMX),y)
SOCFAMILY := IMX
PLATFORM := IMX
KERNEL_CFG := imx_v8_defconfig
MACHINE_LIST := "imx8mpfrdm imx8mpevk imx8mmevk imx8qmmek imx91frdm imx91evk imx91sfrdm imx93evk imx93frdm imx95-15x15-frdm imx95-15x15-evk imx95-19x19-frdm-pro imx95-19x19-evk "
include configs/board/common/imx_memorylayout.cfg
else ifeq ($(CONFIG_PLATFORM_LS),y)
SOCFAMILY := LS
PLATFORM := LS
KERNEL_CFG := defconfig lsdk.config
MACHINE_LIST := ls1028ardb ls1043ardb ls1046ardb lx2160ardb
include configs/board/common/layerscape_memorylayout.cfg
else
SOCFAMILY := IMX
endif

$(foreach soc,$(SOC_LIST), \
    $(if $(filter y,$(CONFIG_SOC_$(shell echo $(soc) | tr a-z A-Z))), \
		$(eval include configs/board/$(soc).conf) \
		$(eval MACHINE := $(shell echo $(soc))) \
	) \
)

ifeq ($(CONFIG_BUILD_VERBOSE),y)
LOG_LEVEL=0
endif

export BOOT_TYPE
export SOCFAMILY DESTARCH DISTRIB_VERSION DEFAULT_REPO_TAG FBDIR DISTRO_SVR_URL MC_FW_VERSION
export ARCH := arm64
export SOCARCH := aarch64
export SYSARCH := arm64
export CROSS_COMPILE := aarch64-linux-gnu-
export DISTROTYPE := debian
export DEFAULT_SOC_FAMILY := IMX
export DISTROVARIANT := server
export FBOUTDIR := $(FBDIR)/build_$(DISTRIB_VERSION)
export PKGDIR := $(FBDIR)/components_$(DISTRIB_VERSION)
export DESTDIR := $(FBOUTDIR)/apps/apps_debian_$(MACHINE)
export RFSDIR := $(FBOUTDIR)/rfs/rootfs_${DISTRIB_VERSION}_debian_$(MACHINE)
export KERNEL_TREE := linux
export MAKE := make
export MAKEFLAGS += -j$(JOBS) -s --no-print-directory
export KERNEL_PATH := $(PKGDIR)/linux/$(KERNEL_TREE)
export KERNEL_OUTPUT_PATH := $(FBOUTDIR)/linux/linux/arm64/$(SOCFAMILY)/output
export INSTALL_MOD_PATH := $(FBOUTDIR)/linux/kernel/arm64/$(SOCFAMILY)
export HOSTARCH := x86_64

export PKG_CONFIG_SYSROOT_DIR := $(RFSDIR)
export LD_LIBRARY_PATH := $(DESTDIR)/usr/lib:$(RFSDIR)/usr/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu
export PKG_CONFIG_PATH := $(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig
export KERNEL_BRANCH := $(DEFAULT_REPO_TAG)
export JOBS := $(CONFIG_JOBS)
export FRAGMENT_CFG =
export SHFLAGS = -c
export GIT_SSL_NO_VERIFY=1

$(shell mkdir -p $(PKGDIR) $(DESTDIR) $(RFSDIR) $(FBOUTDIR))
$(shell mkdir -p $(FBOUTDIR)/firmware/u-boot/$(MACHINE))
$(shell mkdir -p $(FBOUTDIR)/bsp/u-boot/$(MACHINE))
$(shell mkdir -p $(DESTDIR)/{etc,opt} $(DESTDIR)/usr/{lib,bin,include} $(DESTDIR)/usr/local/{lib,bin,include})
$(shell mkdir -p $(FBOUTDIR)/{bsp,linux,rfs,images} $(PKGDIR)/linux $(FBDIR)/{logs,dl})
$(shell mkdir -p $(PKGDIR)/apps/{gopoint,multimedia,graphics,networking,security,utils,ml,robotics} $(KERNEL_OUTPUT_PATH))

$(shell python3 $(FBDIR)/tools/parse_yaml.py $(FBDIR)/configs/repo.yml $(FBDIR)/configs/.repo_pool)


include $(FBDIR)/include/utils.mk
include $(FBDIR)/include/download_repo.mk
include $(FBDIR)/include/patch_apply.mk
include $(FBDIR)/configs/.repo_pool

export LOG_MUTE
export MACHINE

ifdef CONFIG_SECURE_BOOT
	export CONFIG_SECURE_BOOT=y
endif

# ============================================================================
# Main build target - builds based on configuration
# ============================================================================

# Default target
.PHONY: all
all:
	@echo -e "Building for $(MACHINE)"
	@time $(BLD) -m $(MACHINE)
	@echo -e "$(GREEN)Build complete!$(NC)"

# MENUCONFIG_STYLE can be: default, aquatic, monochrome
.PHONY: menuconfig
menuconfig: host-dep
	@$(PYTHON) -m menuconfig
	@$(MAKE) host-dep


# Help target
.PHONY: help
help:
	@echo ""
	@echo ""
	@echo "               Flexbuild Kconfig Build System"
	@echo "==================================================================="
	@echo ""
	@echo "Configuration targets:"
	@echo "  make menuconfig          - Configure flexbuild options"
	@echo "  make kernel-menuconfig   - Configure Linux kernel"
	@echo ""
	@echo "Main targets:"
	@echo "  make linux|kernel        - Build Linux kernel with default config"
	@echo "  make atf                 - Build ARM Trusted Firmware"
	@echo "  make uboot               - Build U-Boot"
	@echo "  make rcw                 - Build RCW for layerscape platform"
	@echo "  make flash.bin           - Build flash.bin image for imx platform"
	@echo "  make bsp                 - Build BSP (ATF, U-Boot, etc.)"
	@echo "  make apps                - Build all applications"
	@echo "  make app_name            - Build a specific application"
	@echo "  make rfs                 - Build root filesystem"
	@echo "  make [ all ]             - Build everything (BSP+kernel+apps+rfs)"
	@echo "                             default target, 'all' can be omitted"
	@echo ""
	@echo "Misc target:"
	@echo "  make packapps|packapp    - Pack NXP apps to a debian package"
	@echo "  make merge-apps          - Merge NXP apps to rootfs"
	@echo "  make packrfs             - Pack and comporess rootfs"
	@echo "  make host-dep            - Build host compiling environment"
	@echo "  make docker              - Construct the docker container"
	@echo "  make show-enabled-apps   - show enabled applications"
	@echo "  make list-all-apps       - list all applications"
	@echo ""
	@echo "Clean targets:"
	@echo "  make clean-linux         - Clean linux kernel, the same as clean-kernel "
	@echo "  make clean-bsp           - Clean firmware composite images"
	@echo "  make clean-apps          - Clean all application components"
	@echo "  make clean-boot          - Clean boot partition images"
	@echo "  make clean-rfs           - Clean root filesystem image"
	@echo "  make distclean           - Clean everything"
	@echo ""
	@echo "==================================================================="
	@echo "Machine:              $(MACHINE)"
	@echo "Version:              $(DISTRIB_VERSION)"
	@echo "Cross Compile:        $(shell $(CROSS_COMPILE)gcc -v 2>&1 | tail -1)"
	@echo "==================================================================="
	@echo ""
	@echo ""


# ============================================================================
# BSP Components
# ============================================================================

include $(FBDIR)/include/func.mk

ifneq ("$(wildcard $(FBDIR)/.config)","")


include $(FBDIR)/src/bsp/Makefile

include $(FBDIR)/src/linux/Makefile

include $(FBDIR)/src/apps/Makefile

endif


# ============================================================================
# Root Filesystem
# ============================================================================

.PHONY: rfs rootfs
rfs rootfs:
	@echo -e "$(GREEN)Building root filesystem$(NC)"
	@echo "Distribution: Debian $(DEBIAN_CODENAME)"
	@echo "Version: $(DEBIAN_VERSION)"
	@$(BLD) rfs -m $(MACHINE) && \
	echo -e "$(GREEN)Root filesystem build complete!$(NC)"


# ============================================================================
# Clean Targets
# ============================================================================

# Declare all clean targets as phony
.PHONY: clean clean-linux clean-kernel clean-bsp clean-boot clean-apps clean-rfs distclean

clean-linux clean-kernel:
	@rm -rf $(FBOUTDIR)/linux

clean-bsp:
	@rm -rf $(FBOUTDIR)/bsp
	@rm -rf $(PKGDIR)/bsp/atf/build
	@if [ -d $(PKGDIR)/bsp/rcw ]; then
		$(MAKE) clean -C $(PKGDIR)/bsp/rcw 2>/dev/null
	fi
	@if [ -d $(PKGDIR)/bsp/mc_utils/config ]; then
		$(MAKE) clean -C $(PKGDIR)/bsp/mc_utils/config
	fi

clean-apps:
	@rm -rf $(DESTDIR)
	@if [ -d $(PKGDIR)/apps/networking/fmc/source ]; then
		$(MAKE) clean -C $(PKGDIR)/apps/networking/fmc/source
	fi
	@if [ -d $(PKGDIR)/apps/security/optee_os ]; then
		$(MAKE) clean -C $(PKGDIR)/apps/security/optee_os ARCH=arm
	fi
	@if [ -d $(PKGDIR)/apps/security/optee_client ]; then
		rm -rf $(PKGDIR)/apps/security/optee_client/out
	fi
	@if [ -d $(PKGDIR)/apps/security/keyctl_caam ]; then
		$(MAKE) clean -C $(PKGDIR)/apps/security/keyctl_caam
	fi
	@if [ -d $(PKGDIR)/apps/security/libpkcs11 ]; then
		$(MAKE) clean -C $(PKGDIR)/apps/security/libpkcs11
	fi
	@rm -rf $(PKGDIR)/apps/security/optee_test/out
	@find $(PKGDIR)/apps -name build_debian_arm64 | xargs rm -rf

clean-boot:
	@rm -rf $(FBOUTDIR)/image/boot_*

clean-rfs:
	@rm -rf $(RFSDIR)
	@rm -rf $(FBOUTDIR)/images/$(notdir $(RFSDIR))*

clean:
	@$(MAKE) clean-bsp
	@$(MAKE) clean-linux
	@$(MAKE) clean-apps

distclean:
	@rm -rf $(FBOUTDIR)/*
	@rm -rf $(PKGDIR)/*
	@rm -rf $(FBDIR)/logs/* $(FBDIR)/logs/.*
	@rm -rf $(FBDIR)/dl/*

# ============================================================================
# Helper targets
# ============================================================================

.PHONY: show-enabled-apps
show-enabled-apps:
	@echo "=== Enabled Application Components ==="
	@echo "Configuration file: $(FBDIR)/.config"
	@echo ""
	@echo "Multimedia:"
	@$(foreach app,$(filter CONFIG_MM_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "Graphics:"
	@$(foreach app,$(filter CONFIG_GFX_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "Networking:"
	@$(foreach app,$(filter CONFIG_NET_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "Security:"
	@$(foreach app,$(filter CONFIG_SEC_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "ML/AI:"
	@$(foreach app,$(filter CONFIG_ML_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "GoPoint:"
	@$(foreach app,$(filter CONFIG_GP_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "Utils:"
	@$(foreach app,$(filter CONFIG_UTILS_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))
	@echo ""
	@echo "Robotics:"
	@$(foreach app,$(filter CONFIG_ROBOTICS_%,$(.VARIABLES)),\
$(if $(filter y,$($(app))),echo "  - $(app) = $($(app))";))

.PHONY: list-all-apps
list-all-apps:
	@echo "=== All Available Applications ==="
	@echo "Multimedia: $(MM_MODULES)"
	@echo ""
	@echo "Graphics: $(GFX_MODULES)"
	@echo ""
	@echo "Networking: $(NET_MODULES)"
	@echo ""
	@echo "Security: $(SEC_MODULES)"
	@echo ""
	@echo "ML/AI: $(ML_MODULES)"
	@echo ""
	@echo "GoPoint: $(GP_MODULES)"
	@echo ""
	@echo "Utils: $(UTILS_MODULES)"
	@echo ""
	@echo "Robotics: $(ROBOTICS_MODULES)"


