#
# Copyright 2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK Application Components
#

# ============================================================================
# Security Components
# ============================================================================




# ============================================================================
# Define all possible security modules
# ============================================================================
SEC_MODULES := \
    crconf \
    cst \
    ecc_example \
    imx_secure_enclave \
    imx_smw \
    keyctl_caam \
    libpkcs11 \
    mbedtls \
    openssl \
    openssl_provider_se05x \
    optee_client \
    optee_os \
    optee_test \
    secure_obj

# ============================================================================
# Conditionally include enabled modules based on Kconfig
# ============================================================================
APPS_SEC-y :=

# Add modules based on CONFIG_SEC_* settings
APPS_SEC-$(CONFIG_SEC_CRCONF) += crconf
APPS_SEC-$(CONFIG_SEC_CST) += cst
APPS_SEC-$(CONFIG_SEC_ECC_EXAMPLE) += ecc_example
APPS_SEC-$(CONFIG_SEC_IMX_SECURE_ENCLAVE) += imx_secure_enclave
APPS_SEC-$(CONFIG_SEC_IMX_SMW) += imx_smw
APPS_SEC-$(CONFIG_SEC_KEYCTL_CAAM) += keyctl_caam
APPS_SEC-$(CONFIG_SEC_LIBPKCS11) += libpkcs11
APPS_SEC-$(CONFIG_SEC_MBEDTLS) += mbedtls
APPS_SEC-$(CONFIG_SEC_OPENSSL) += openssl
APPS_SEC-$(CONFIG_SEC_OPENSSL_PROVIDER_SE05X) += openssl_provider_se05x
APPS_SEC-$(CONFIG_SEC_OPTEE_CLIENT) += optee_client
APPS_SEC-$(CONFIG_SEC_OPTEE_OS) += optee_os
APPS_SEC-$(CONFIG_SEC_OPTEE_TEST) += optee_test
APPS_SEC-$(CONFIG_SEC_SECURE_OBJ) += secure_obj

# Create alias for backward compatibility
APPS_SEC := $(APPS_SEC-y)

# ============================================================================
# Include makefiles for enabled modules
# ============================================================================
$(foreach m,$(APPS_SEC-y), \
    $(eval include $(FBDIR)/src/apps/security/$(m).mk))

# ============================================================================
# Security target using APPS_SEC-y
# ============================================================================
.PHONY: security
security: $(APPS_SEC-y)
