# Copyright 2023-2026 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
CONFIG_APP_FR1_FR2_TEST_TOOL ?= n

fr1_fr2_test_tool:
	@set -e; \
	if [ "$(strip $(CONFIG_APP_FR1_FR2_TEST_TOOL))" != "y" ]; then \
		echo "Skipping fr1_fr1_test_tool: CONFIG_APP_FR1_FR2_TEST_TOOL!='y' (current='$(strip $(CONFIG_APP_FR1_FR2_TEST_TOOL))')"; \
		exit 0; \
	fi && \
	$(call download_repo,fr1_fr2_test_tool,apps/networking,git)
	$(call patch_apply,fr1_fr2_test_tool,apps/networking) && \
	$(call fbprint_b,"fr1_fr2_test_tool")
	cd $(NETDIR)/fr1_fr2_test_tool && \
	if [[ ! -e $(DESTDIR)/root ]]; then  mkdir $(DESTDIR)/root; fi && \
	mkdir -p $(DESTDIR)/root/fr1_fr2_test_tool && \
	cp -rf * $(DESTDIR)/root/fr1_fr2_test_tool/ && \
	$(call fbprint_d,"fr1_fr2_test_tool")
