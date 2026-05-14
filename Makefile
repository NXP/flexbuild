# Flexbuild Kconfig-based Build System
# This Makefile integrates Kconfig configuration with flexbuild

.ONESHELL:
SHELL=/bin/bash
.SHELLFLAGS = -ec
.DEFAULT_GOAL := help

DISTRIB_VERSION := lsdk2606
DEFAULT_REPO_TAG := lf-6.12.49-2.2.0
FBDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BLD := $(FBDIR)/tools/flex-builder
FINST := $(FBDIR)/tools/flex-installer
PYTHON := python3
DISTRO_SVR_URL := https://www.nxp.com/lgfiles/sdk
DESTARCH := arm64
DISTRIB_NAME := "NXP Debian Linux SDK"
DEBIAN_CODENAME := trixie
DEBIAN_VERSION := 13

LOG_LEVEL ?= 2

NO_CONFIG_FIXED   := menuconfig help docker list config distclean %_defconfig clean-%
CURRENT_GOALS     := $(or $(MAKECMDGOALS),help)
IS_DOCKER         := $(wildcard /.dockerenv)

# Only the docker and help targets can be run inside Docker
ifneq ($(filter-out docker help list,$(CURRENT_GOALS)),)
    ifeq ($(IS_DOCKER),)
        $(info ERROR: Must be run inside a Docker container!)
        $(info Please run 'make docker' first.)
        $(info )
        $(error Build stopped)
    endif
endif

# Only the clean-%, distclean, config, menuconfig, and %_defconfig targets
# can be run without a .config file
NEED_CONFIG_GOALS := $(filter-out $(NO_CONFIG_FIXED), $(CURRENT_GOALS))
ifneq ($(NEED_CONFIG_GOALS),)
    ifeq ($(wildcard $(FBDIR)/.config),)
        $(info ERROR: .config not found!)
        $(info Please run 'make menuconfig' or '<machine>_defconfig' first.)
        $(info )
        $(error Build stopped)
    endif
endif

export PATH := $(FBDIR):$(FBDIR)/tools:$(PATH)
export GIT_SSL_NO_VERIFY := 1

# Load configuration
-include $(FBDIR)/.config
ifneq ($(wildcard $(FBDIR)/.config),)
    CONFIG_VARS := $(shell grep -o '^CONFIG_[^=]*' $(FBDIR)/.config)
    export $(CONFIG_VARS)
endif

ifeq ($(CONFIG_PLATFORM_IMX),y)
SOCFAMILY := IMX
KERNEL_CFG := imx_v8_defconfig
else
SOCFAMILY := LS
KERNEL_CFG := defconfig lsdk.config
endif

MACHINE := $(strip $(subst ",,$(CONFIG_MACHINE_NAME)))

ifeq ($(CONFIG_BUILD_VERBOSE),y)
LOG_LEVEL=0
endif

export JOBS := $(CONFIG_JOBS)
export DEBIAN_VERSION DEBIAN_CODENAME
export DEBIAN_MIRRORS := $(strip $(subst ",,$(CONFIG_DEBIAN_MIRRORS)))
export SOCFAMILY DESTARCH DISTRIB_VERSION DEFAULT_REPO_TAG FBDIR DISTRO_SVR_URL
export ARCH := arm64
export CROSS_COMPILE := aarch64-linux-gnu-
export DISTROTYPE := debian
export DISTROVARIANT := server
export FBOUTDIR := $(FBDIR)/build_$(DISTRIB_VERSION)
export PKGDIR := $(FBDIR)/components_$(DISTRIB_VERSION)
export DESTDIR := $(FBOUTDIR)/apps/apps_debian_$(MACHINE)
export RFSDIR := $(FBOUTDIR)/rfs/rootfs_${DISTRIB_VERSION}_debian_$(MACHINE)
export MAKE := make
export MAKEFLAGS += -j$(JOBS) --no-print-directory
export KERNEL_PATH := $(PKGDIR)/linux/linux
export KERNEL_OUTPUT_PATH := $(FBOUTDIR)/linux/linux/arm64/$(SOCFAMILY)/output
export INSTALL_MOD_PATH := $(FBOUTDIR)/linux/kernel/arm64/$(SOCFAMILY)
export HOSTARCH := x86_64

export PKG_CONFIG_SYSROOT_DIR := $(RFSDIR)
export LD_LIBRARY_PATH := $(DESTDIR)/usr/lib:$(RFSDIR)/usr/lib:$(RFSDIR)/usr/lib/aarch64-linux-gnu
export PKG_CONFIG_PATH := $(DESTDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/pkgconfig:$(RFSDIR)/usr/lib/aarch64-linux-gnu/pkgconfig:$(RFSDIR)/usr/share/pkgconfig
export KERNEL_BRANCH := $(DEFAULT_REPO_TAG)
export FRAGMENT_CFG =
export CFGLISTYML := sdk.yml
export SHFLAGS = -c
export GIT_SSL_NO_VERIFY=1
export LOG_MUTE
export MACHINE

RFS_FILE := $(RFSDIR)/etc/buildinfo
KOUTDIR := $(KERNEL_OUTPUT_PATH)/$(KERNEL_BRANCH)
KTGT_DIR := $(FBOUTDIR)/linux/linux/arm64/$(SOCFAMILY)
KERNEL_IMAGE := $(KTGT_DIR)/Image
KHEADER_FILE := $(DESTDIR)/usr/include/linux/version.h

include $(FBDIR)/include/utils.mk
include $(FBDIR)/include/download_repo.mk
include $(FBDIR)/include/patch_apply.mk

$(shell mkdir -p $(PKGDIR) $(FBOUTDIR))
$(shell mkdir -p $(FBOUTDIR)/{apps,bsp,linux,rfs,images,boot} $(PKGDIR)/{linux,bsp} $(FBDIR)/{logs,dl})
$(shell mkdir -p $(PKGDIR)/apps/{gopoint,multimedia,graphics,networking,security,utils,ml,robotics})

# ============================================================================
# Main build target - builds based on configuration
# ============================================================================

# Default target
.PHONY: all
all:
	@start_time=$$(date +%s)
	echo -e "Building for $(MACHINE)"
	$(MAKE) rfs
	$(MAKE) linux
	$(MAKE) linux-headers
	$(MAKE) linux-modules
	$(MAKE) apps
	if [ "$(CONFIG_PLATFORM_IMX)" = "y" ]; then
		$(MAKE) flash.bin
	else
		$(MAKE) bsp
	fi
	$(MAKE) boot
	$(MAKE) merge-apps
	$(MAKE) packrfs
	end_time=$$(date +%s)
	duration=$$((end_time - start_time))
	echo -e "$(GREEN)Build complete!$(NC)"
	echo "Total build time: $$(($$duration / 60))m $$(($$duration % 60))s"

LOG_FILE=$(FBDIR)/logs/build_$(MACHINE)_$(shell date +%Y%m%d_%H%M%S).log
all-log:
	@script -e -q -c "$(MAKE) all" /dev/null | tee -a $(LOG_FILE)
	@echo "Log saved to: $(LOG_FILE)"

# MENUCONFIG_STYLE can be: default, aquatic, monochrome
.PHONY: menuconfig
menuconfig:
	@$(PYTHON) -m menuconfig
	$(PYTHON) tools/kconfig_hooks.py
	$(MAKE) parse-sdk-config
	$(MAKE) host-dep

.PHONY: %_defconfig
%_defconfig:
	@BOARD=$(@:_defconfig=)
	echo "==> Generating defconfig for $$BOARD"
	$(PYTHON) tools/gen_defconfig.py Kconfig $$BOARD
	$(PYTHON) tools/kconfig_hooks.py
	$(MAKE) parse-sdk-config
	$(MAKE) host-dep

.PHONY: config
config:
	@if [ -z "$(CONFIG)" ]; then
		echo "ERROR: <CONFIG> parameter is required!" >&2
		echo "" >&2
		echo "Usage: make config CONFIG=<config-file>" >&2
		exit 1
	fi
	if [ ! -f "$(CONFIG)" ]; then
		echo "ERROR: CONFIG file not found: $(CONFIG)" >&2
		echo "" >&2
		exit 1
	fi
	echo "==> Generating .config from $(CONFIG)"
	$(PYTHON) tools/gen_config_from_file.py Kconfig $(CONFIG)
	$(PYTHON) tools/kconfig_hooks.py
	$(MAKE) parse-sdk-config
	$(MAKE) host-dep

# Create a new target for SDK configuration parsing
.PHONY: parse-sdk-config
parse-sdk-config:
	@CUSTOM_CONFIG=$$(echo '$(CONFIG_CUSTOM_SDK_CONFIG)' | sed 's/"//g' | xargs)
	if [ -n "$$CUSTOM_CONFIG" ]; then
		SDK_YML=$(FBDIR)/configs/$$CUSTOM_CONFIG
	else
		SDK_YML=$(FBDIR)/configs/sdk.yml
	fi
	$(PYTHON) $(FBDIR)/tools/parse_yaml.py $$SDK_YML $(FBDIR)/configs/.sdk.cfg
	chmod 666 $(FBDIR)/configs/.sdk.cfg

# Help target
.PHONY: help
help:
	@echo ""
	@echo ""
	@echo "               NXP Debian Kconfig Build System"
	@echo "==================================================================="
	@echo ""
	@echo "Main targets:"
	@echo "  make all                 - Build everything (BSP+kernel+apps+rfs)"
	@echo "  make menuconfig          - Configure flexbuild options"
	@echo "  make <machine>_defconfig - Use default config for <machine>"
	@echo "  make linux               - Build Linux kernel with default config"
	@echo "  make linux-menuconfig    - Configure Linux kernel"
	@echo "  make atf                 - Build ARM Trusted Firmware"
	@echo "  make uboot               - Build U-Boot"
	@echo "  make rcw                 - Build RCW for layerscape platform"
	@echo "  make flash.bin           - Build flash.bin image for imx platform"
	@echo "  make bsp                 - Build BSP (ATF, U-Boot, etc.)"
	@echo "  make apps                - Build all applications"
	@echo "  make <app_name>          - Build a specific application"
	@echo "  make rfs                 - Build root filesystem"
	@echo ""
	@echo "Misc target:"
	@echo "  make docker              - Construct the docker container"
	@echo "  make list                - List all supported machines"
	@echo "  make packapps            - Pack NXP apps to a debian package"
	@echo "  make merge-apps          - Merge NXP apps to rootfs"
	@echo "  make packrfs             - Pack and comporess rootfs"
	@echo "  make wic                 - Generate the WIC file and compress it"
	@echo "  make show-enabled-apps   - Show enabled applications"
	@echo "  make list-all-apps       - List all applications"
	@echo "  make [ help ]            - Print this menu, default target"
	@echo ""
	@echo ""
	@echo "Clean targets:"
	@echo "  make clean-linux         - Clean linux kernel, the same as clean-kernel "
	@echo "  make clean-bsp           - Clean firmware composite images"
	@echo "  make clean-apps          - Clean all application components"
	@echo "  make clean-boot          - Clean boot partition images"
	@echo "  make clean-rfs           - Clean root filesystem image"
	@echo "  make clean-config        - Clean .config configuration file"
	@echo "  make distclean           - Clean everything including source code"
	@echo ""
	@echo ""
	@echo "==================================================================="
	@echo "Current machine:           $(MACHINE)"
	@echo "LSDK Version:              $(DISTRIB_VERSION)"
	@echo "==================================================================="
	@echo ""
	@echo ""


# ============================================================================
# BSP Components
# ============================================================================

ifneq ($(wildcard .config),)

include configs/board/$(MACHINE).conf

-include $(FBDIR)/configs/.sdk.cfg

include $(FBDIR)/src/Makefile

endif

include $(FBDIR)/include/func.mk

# ============================================================================
# Clean Targets
# ============================================================================

# Declare all clean targets as phony
.PHONY: clean-linux clean-kernel clean-bsp clean-boot clean-apps clean-rfs distclean

clean-linux clean-kernel:
	@[ -d "$(FBOUTDIR)/linux" ]  && shopt -s dotglob && rm -rf "$(FBOUTDIR)"/linux/* 2>/dev/null || true

clean-bsp:
	@[ -d "$(FBOUTDIR)/bsp" ]  && shopt -s dotglob && rm -rf "$(FBOUTDIR)"/bsp/* 2>/dev/null || true
	@rm -rf "$(PKGDIR)/bsp/atf/build"
	@if [ -d "$(PKGDIR)/bsp/rcw" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/bsp/rcw" >/dev/null; \
	fi
	@if [ -d "$(PKGDIR)/bsp/mc_utils/config" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/bsp/mc_utils/config" >/dev/null; \
	fi

clean-apps:
	@rm -rf "$(DESTDIR)"
	@if [ -d "$(PKGDIR)/apps/networking/fmc/source" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/apps/networking/fmc/source"; \
	fi
	@if [ -d "$(PKGDIR)/apps/security/optee_os" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/apps/security/optee_os" ARCH=arm; \
	fi
	@rm -rf "$(PKGDIR)/apps/security/optee_client/out"
	@if [ -d "$(PKGDIR)/apps/security/keyctl_caam" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/apps/security/keyctl_caam"; \
	fi
	@if [ -d "$(PKGDIR)/apps/security/libpkcs11" ]; then \
		$(MAKE) clean -C "$(PKGDIR)/apps/security/libpkcs11"; \
	fi
	@rm -rf "$(PKGDIR)/apps/security/optee_test/out"
	@find "$(PKGDIR)/apps" -name build_debian_arm64 -exec rm -rf {} +

clean-boot:
	@rm -rf "$(FBOUTDIR)/image"/boot_*

clean-rfs:
	@rm -rf "$(RFSDIR)"
	@rm -rf "$(FBOUTDIR)/images/$(notdir $(RFSDIR))"*

.NOTPARALLEL: distclean
distclean:
	@[ -d "$(FBOUTDIR)" ]     && shopt -s dotglob && rm -rf "$(FBOUTDIR)"/*/* 2>/dev/null || true
	@[ -d "$(PKGDIR)/apps" ]  && shopt -s dotglob && rm -rf "$(PKGDIR)/apps"/*/* 2>/dev/null || true
	@[ -d "$(PKGDIR)/bsp" ]   && shopt -s dotglob && rm -rf "$(PKGDIR)/bsp"/* 2>/dev/null || true
	@[ -d "$(PKGDIR)/linux" ] && shopt -s dotglob && rm -rf "$(PKGDIR)/linux"/* 2>/dev/null || true
	@[ -d "$(FBDIR)/logs" ]   && shopt -s dotglob && rm -rf "$(FBDIR)/logs"/* 2>/dev/null || true
	@[ -d "$(FBDIR)/dl" ]     && shopt -s dotglob && rm -rf "$(FBDIR)/dl"/* 2>/dev/null || true
	@rm -f "$(FBDIR)/.config"

clean-config:
	@rm -f "$(FBDIR)/.config"

# ============================================================================
# Helper targets
# ============================================================================

.PHONY: list
list:
	@for conf in configs/board/*.conf; do
		if [ -f "$$conf" ]; then
			. "$$conf"
			echo "  - $$machine"
		fi
	done

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


