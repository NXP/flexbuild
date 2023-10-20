# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause


bsp_repo_fetch:
	@echo -e "\nfetch bsp repositories"
	@$(call repo-mngr,fetch,$(BSP_REPO_LIST),bsp)

bsp_repo_update_branch:
	@echo -e "\nbsp repositories update for branch"
	@$(call repo-mngr,branch,$(BSP_REPO_LIST),bsp)

bsp_repo_update_tag:
	@echo -e "\nbsp repositories update for tag"
	@$(call repo-mngr,tag,$(BSP_REPO_LIST),bsp)

bsp_repo_update_latest:
	@echo -e "\nbsp repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(BSP_REPO_LIST),bsp)

bsp_repo_update_commit:
	@echo -e "\nbsp repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(BSP_REPO_LIST),bsp)

linux_repo_fetch:
	@echo -e "\nfetch linux repositories"
	@$(call repo-mngr,fetch,$(LINUX_REPO_LIST),linux)

linux_repo_update_branch:
	@echo -e "\nlinux repositories update for branch"
	@$(call repo-mngr,branch,$(LINUX_REPO_LIST),linux)

linux_repo_update_tag:
	@echo -e "\nlinux repositories update for tag"
	@$(call repo-mngr,tag,$(LINUX_REPO_LIST),linux)

linux_repo_update_latest:
	@echo -e "\nlinux repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(LINUX_REPO_LIST),linux)

linux_repo_update_commit:
	@echo -e "\nlinux repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(LINUX_REPO_LIST),linux)

networking_repo_fetch:
	@echo -e "\nfetch networking repositories: $(NETWORKING_REPO_LIST)"
	@$(call repo-mngr,fetch,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_branch:
	@echo -e "\nnetworking repositories update for branch"
	@$(call repo-mngr,branch,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_tag:
	@echo -e "\nnetworking repositories update for tag"
	@$(call repo-mngr,tag,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_latest:
	@echo -e "\nnetworking repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(NETWORKING_REPO_LIST),apps/networking)

networking_repo_update_commit:
	@echo -e "\nnetworking repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(NETWORKING_REPO_LIST),apps/networking)

graphics_repo_fetch:
	@echo -e "\nfetch graphics repositories: $(GRAPHICS_REPO_LIST)"
	@$(call repo-mngr,fetch,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_branch:
	@echo -e "\ngraphics repositories update for branch"
	@$(call repo-mngr,branch,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_tag:
	@echo -e "\ngraphics repositories update for tag"
	@$(call repo-mngr,tag,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_latest:
	@echo -e "\ngraphics repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(GRAPHICS_REPO_LIST),apps/graphics)

graphics_repo_update_commit:
	@echo -e "\ngraphics repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(GRAPHICS_REPO_LIST),apps/graphics)

multimedia_repo_fetch:
	@echo -e "\nfetch multimedia repositories: $(MULTIMEDIA_REPO_LIST)"
	@$(call repo-mngr,fetch,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_branch:
	@echo -e "\nmultimedia repositories update for branch"
	@$(call repo-mngr,branch,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_tag:
	@echo -e "\nmultimedia repositories update for tag"
	@$(call repo-mngr,tag,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_latest:
	@echo -e "\nmultimedia repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

multimedia_repo_update_commit:
	@echo -e "\nmultimedia repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(MULTIMEDIA_REPO_LIST),apps/multimedia)

security_repo_fetch:
	@echo -e "\nfetch security repositories: $(SECURITY_REPO_LIST)"
	@$(call repo-mngr,fetch,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_branch:
	@echo -e "\nsecurity repositories update for branch"
	@$(call repo-mngr,branch,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_tag:
	@echo -e "\nsecurity repositories update for tag"
	@$(call repo-mngr,tag,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_latest:
	@echo -e "\nsecurity repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(SECURITY_REPO_LIST),apps/security)

security_repo_update_commit:
	@echo -e "\nsecurity repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(SECURITY_REPO_LIST),apps/security)

connectivity_repo_fetch:
	@echo -e "\nfetch connectivity repositories: $(connectivity_REPO_LIST)"
	@$(call repo-mngr,fetch,$(CONNECTIVITY_REPO_LIST),apps/connectivity)

connectivity_repo_update_branch:
	@echo -e "\nconnectivity repositories update for branch"
	@$(call repo-mngr,branch,$(CONNECTIVITY_REPO_LIST),apps/connectivity)

connectivity_repo_update_tag:
	@echo -e "\nconnectivity repositories update for tag"
	@$(call repo-mngr,tag,$(CONNECTIVITY_REPO_LIST),apps/connectivity)

connectivity_repo_update_latest:
	@echo -e "\nconnectivity repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(CONNECTIVITY_REPO_LIST),apps/connectivity)

connectivity_repo_update_commit:
	@echo -e "\nconnectivity repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(CONNECTIVITY_REPO_LIST),apps/connectivity)

utils_repo_fetch:
	@echo -e "\nfetch utils repositories: $(UTILS_REPO_LIST)"
	@$(call repo-mngr,fetch,$(UTILS_REPO_LIST),apps/utils)

utils_repo_update_branch:
	@echo -e "\nutils repositories update for branch"
	@$(call repo-mngr,branch,$(UTILS_REPO_LIST),apps/utils)

utils_repo_update_tag:
	@echo -e "\nutils repositories update for tag"
	@$(call repo-mngr,tag,$(UTILS_REPO_LIST),apps/utils)

utils_repo_update_latest:
	@echo -e "\nutils repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(UTILS_REPO_LIST),apps/utils)

utils_repo_update_commit:
	@echo -e "\nutils repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(UTILS_REPO_LIST),apps/utils)

ml_repo_fetch:
	@echo -e "\nfetch eIQ repositories: $(ML_REPO_LIST)"
	@$(call repo-mngr,fetch,$(ML_REPO_LIST),apps/ml)

ml_repo_update_branch:
	@echo -e "\neIQ repositories update for branch"
	@$(call repo-mngr,branch,$(ML_REPO_LIST),apps/ml)

ml_repo_update_tag:
	@echo -e "\neIQ repositories update for tag"
	@$(call repo-mngr,tag,$(ML_REPO_LIST),apps/ml)

ml_repo_update_latest:
	@echo -e "\neIQ repositories update to latest HEAD commit"
	@$(call repo-mngr,update,$(ML_REPO_LIST),apps/ml)

ml_repo_update_commit:
	@echo -e "\neIQ repositories update to specified commit ID"
	@$(call repo-mngr,commit,$(ML_REPO_LIST),apps/ml)
