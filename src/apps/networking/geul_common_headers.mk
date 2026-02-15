# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_GEUL_COMMON_HEADERS ?= n


geul_common_headers:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_GEUL_COMMON_HEADERS))" != "y" ]; then \
		echo "Skipping geul_common_headers: CONFIG_APP_GEUL_COMMON_HEADERS!='y' (current='$(strip $(CONFIG_APP_GEUL_COMMON_HEADERS))')"; \
		exit 0; \
	fi && \
	$(call download_repo,geul_common_headers,apps/networking,git) && \
	$(call patch_apply,geul_common_headers,apps/networking) && \
	$(call fbprint_b,"geul_common_headers") && \
	$(call fbprint_d,"geul_common_headers")
