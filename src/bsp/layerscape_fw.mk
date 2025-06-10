#
# Copyright 2017-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components


uefi_machine_list = ls1043ardb ls1046ardb ls2088ardb lx2160ardb

uefi_bin_url = https://github.com/nxp-qoriq/qoriq-uefi-binary.git


layerscape_fw: rcw mc_bin mc_utils fm_ucode qe_ucode dp_fw_cadence phy_cortina phy_inphi pfe_bin ddr_phy_bin
	@touch $(FBOUTDIR)/bsp/.lsfwdone



uefi uefi_bin:
	 $(call fbprint_b,"uefi_bin") && \
	 git clone $(uefi_bin_url) $(BSPDIR)/qoriq-uefi-binary -b $(DEFAULT_REPO_TAG) && \
	 cd $(BSPDIR) && \
	 for brd in $(uefi_machine_list); do \
	     mkdir -p $(FBOUTDIR)/bsp/uefi/$$brd; \
	     if [ ! -f $(FBOUTDIR)/bsp/uefi/$$brd/*RDB_EFI* ]; then \
		cp uefi_bin/$$brd/*.fd $(FBOUTDIR)/bsp/uefi/$$brd/; \
	     fi; \
	 done && \
	 mkdir -p $(FBOUTDIR)/bsp/uefi/grub && \
	 cp uefi_bin/grub/BOOTAA64.EFI $(FBOUTDIR)/bsp/uefi/grub && \
	 $(call fbprint_d,"UEFI_BIN")




mc_utils:
	@ $(call repo-mngr,fetch,mc_utils,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -h $(FBOUTDIR)/bsp/mc_utils ]; then \
	     ln -s $(BSPDIR)/mc_utils $(FBOUTDIR)/bsp/mc_utils; \
	 fi && \
	 $(MAKE) -C mc_utils/config $(LOG_MUTE) && \
	 $(call fbprint_d,"mc_utils")



fm_ucode:
	@$(call repo-mngr,fetch,fm_ucode,bsp)
	@if [ ! -h $(FBOUTDIR)/bsp/fm_ucode ]; then \
	     ln -s $(BSPDIR)/fm_ucode $(FBOUTDIR)/bsp/fm_ucode; \
	 fi && \
	 $(call fbprint_d,"fm_ucode")



qe_ucode:
	@$(call repo-mngr,fetch,qe_ucode,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/qe_ucode ]; then \
	     ln -s $(BSPDIR)/qe_ucode $(FBOUTDIR)/bsp/qe_ucode; \
	 fi && \
	 $(call fbprint_d,"qe_ucode")



dp_fw_cadence:
	@if [ ! -d $(BSPDIR)/firmware-imx/firmware/hdmi/cadence ]; then \
             cd $(BSPDIR) && wget -q $(repo_firmware_imx_bin_url) -O firmware_imx.bin $(LOG_MUTE) && \
             chmod +x firmware_imx.bin && \
             ./firmware_imx.bin --auto-accept $(LOG_MUTE) && \
	     mv firmware-imx* firmware-imx && rm -f firmware_imx.bin; \
	 fi && \
	 if [ ! -L $(FBOUTDIR)/bsp/dp_fw_cadence ]; then \
	     ln -sf $(BSPDIR)/firmware-imx/firmware/hdmi/cadence $(FBOUTDIR)/bsp/dp_fw_cadence; \
	 fi && \
	 $(call fbprint_d,"dp_fw_cadence")



mc_bin:
	@$(call repo-mngr,fetch,mc_bin,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -L $(FBOUTDIR)/bsp/mc_bin ]; then \
	     ln -s $(BSPDIR)/mc_bin $(FBOUTDIR)/bsp/mc_bin; \
	 fi && \
	 $(call fbprint_d,"mc_bin")



phy_cortina:
	@$(call repo-mngr,fetch,phy_cortina,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/phy_cortina ]; then \
	     ln -s $(BSPDIR)/phy_cortina $(FBOUTDIR)/bsp/phy_cortina; \
	 fi && \
	 $(call fbprint_d,"phy_cortina")



phy_inphi:
	@$(call repo-mngr,fetch,phy_inphi,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/phy_inphi ]; then \
	     ln -s $(BSPDIR)/phy_inphi $(FBOUTDIR)/bsp/phy_inphi; \
	 fi && \
	 $(call fbprint_d,"phy_inphi")



pfe_bin:
	@$(call repo-mngr,fetch,pfe_bin,bsp) && \
	 if [ ! -h $(FBOUTDIR)/bsp/pfe_bin ]; then \
	     ln -s $(BSPDIR)/pfe_bin $(FBOUTDIR)/bsp/pfe_bin; \
	 fi && \
	 $(call fbprint_d,"pfe_bin")



ddr_phy_bin:
	@$(call repo-mngr,fetch,ddr_phy_bin,bsp) && \
	 if [ ! -f $(FBOUTDIR)/bsp/ddr_phy_bin/fip_ddr.bin ]; then \
	     ln -sf $(BSPDIR)/ddr_phy_bin $(FBOUTDIR)/bsp/ddr_phy_bin; \
	     cp -f $(BSPDIR)/ddr_phy_bin/lx2160a/*.bin $(BSPDIR)/atf/; \
	 fi && \
	 $(call fbprint_d,"ddr_phy_bin")
