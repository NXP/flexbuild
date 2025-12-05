#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components



layerscape_fw: mc_bin mc_utils fm_ucode qe_ucode dp_fw_cadence phy_cortina phy_inphi pfe_bin ddr_phy_bin
	@touch $(FBDIR)/logs/.lsfwdone


UTILSDIR = $(PKGDIR)/apps/utils


mc_utils:
	@ $(call download_repo,mc_utils,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -h $(FBOUTDIR)/bsp/mc_utils ]; then \
	     ln -s $(BSPDIR)/mc_utils $(FBOUTDIR)/bsp/mc_utils; \
	 fi && \
	 $(MAKE) -C mc_utils/config $(LOG_MUTE) && \
	 $(call fbprint_d,"mc_utils")



fm_ucode:
	@$(call download_repo,fm_ucode,bsp)
	@if [ ! -h $(FBOUTDIR)/bsp/fm_ucode ]; then \
	     ln -s $(BSPDIR)/fm_ucode $(FBOUTDIR)/bsp/fm_ucode; \
	 fi && \
	 $(call fbprint_d,"fm_ucode")



qe_ucode:
	@$(call download_repo,qe_ucode,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/qe_ucode ]; then \
	     ln -s $(BSPDIR)/qe_ucode $(FBOUTDIR)/bsp/qe_ucode; \
	 fi && \
	 $(call fbprint_d,"qe_ucode")



dp_fw_cadence:
	@bld firmware_imx -m $(MACHINE); \
	$(call fbprint_d,"dp_fw_cadence")



mc_bin:
	@$(call download_repo,mc_bin,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -L $(FBOUTDIR)/bsp/mc_bin ]; then \
	     ln -s $(BSPDIR)/mc_bin $(FBOUTDIR)/bsp/mc_bin; \
	 fi && \
	 $(call fbprint_d,"mc_bin")



phy_cortina:
	@$(call download_repo,phy_cortina,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/phy_cortina ]; then \
	     ln -s $(BSPDIR)/phy_cortina $(FBOUTDIR)/bsp/phy_cortina; \
	 fi && \
	 $(call fbprint_d,"phy_cortina")



phy_inphi:
	@$(call download_repo,phy_inphi,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/phy_inphi ]; then \
	     ln -s $(BSPDIR)/phy_inphi $(FBOUTDIR)/bsp/phy_inphi; \
	 fi && \
	 $(call fbprint_d,"phy_inphi")



pfe_bin:
	@$(call download_repo,pfe_bin,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/pfe_bin ]; then \
	     ln -s $(BSPDIR)/pfe_bin $(FBOUTDIR)/bsp/pfe_bin; \
	 fi && \
	 $(call fbprint_d,"pfe_bin")



ddr_phy_bin:
	@$(call download_repo,ddr_phy_bin,bsp) && \
	 if [ ! -f $(FBOUTDIR)/bsp/ddr_phy_bin/fip_ddr.bin ]; then \
	     ln -sf $(BSPDIR)/ddr_phy_bin $(FBOUTDIR)/bsp/ddr_phy_bin; \
	     cp -f $(BSPDIR)/ddr_phy_bin/lx2160a/*.bin $(BSPDIR)/atf/; \
	 fi && \
	 $(call fbprint_d,"ddr_phy_bin")
