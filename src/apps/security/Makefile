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
# Automatically include enabled modules and build APPS_SEC
# ============================================================================
APPS_SEC :=

$(foreach m,$(SEC_MODULES), \
    $(eval _cfg := CONFIG_SEC_$(shell echo $(m) | tr a-z A-Z)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval include $(FBDIR)/src/apps/security/$(m).mk)) \
    $(if $(filter y,$($(_cfg))), \
        $(eval APPS_SEC += $(m))) \
)

# ============================================================================
# Security target using APPS_SEC
# ============================================================================
.PHONY: security
security: $(APPS_SEC)

