#
# Copyright 2017-2021 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#
# SDK BSP Components


uefi_machine_list = ls1043ardb ls1046ardb ls2088ardb lx2160ardb_rev2

dp_firmware_cadence_url ?= https://www.nxp.com/lgfiles/sdk/lsdk2108/firmware-cadence-lsdk2108.bin

repo_grub_url ?= git://git.savannah.gnu.org/grub.git
repo_grub_commit ?= 2df291226638261d50



layerscape_fw: rcw uefi mc_bin mc_utils fm_ucode qe_ucode dp_firmware_cadence phy_cortina phy_inphi pfe_bin ddr_phy_bin
	@touch $(FBOUTDIR)/bsp/.lsfwdone



uefi uefi_bin:
ifeq ($(CONFIG_UEFI_BIN), "y")
	 $(call repo-mngr,fetch,uefi_bin,bsp) && \
	 cd $(BSPDIR) && \
	 for brd in $(uefi_machine_list); do \
	     if [ $$brd = lx2160ardb_rev2 ]; then brd=$${brd:0:10}; fi; \
	     mkdir -p $(FBOUTDIR)/bsp/uefi/$$brd; \
	     if [ ! -f $(FBOUTDIR)/bsp/uefi/$$brd/*RDB_EFI* ]; then \
		cp uefi_bin/$$brd/*.fd $(FBOUTDIR)/bsp/uefi/$$brd/; \
	     fi; \
	 done && mkdir -p $(FBOUTDIR)/bsp/uefi/grub && \
	 cp uefi_bin/grub/BOOTAA64.EFI $(FBOUTDIR)/bsp/uefi/grub && \
	 $(call fbprint_d,"UEFI_BIN")
endif



grub:
ifeq ($(CONFIG_GRUB), "y")
	@$(call fbprint_b,"grub") && \
	 $(call repo-mngr,fetch,grub,bsp) && cd $(BSPDIR)/grub && \
	 ./bootstrap && ./autogen.sh && \
	 ./configure --target=aarch64-linux-gnu && \
	 make && echo 'configfile ${cmdpath}/grub.cfg' > grub.cfg && \
	 grub-mkstandalone --directory=./grub-core -O arm64-efi -o BOOTAA64.EFI \
			   --modules "part_gpt part_msdos" /boot/grub/grub.cfg=./grub.cfg && \
	 mkdir -p $(FBOUTDIR)/bsp/grub && cp -f BOOTAA64.EFI $(FBOUTDIR)/bsp/grub && \
	$(call fbprint_d,"grub")
endif



mc_utils:
	@ $(call repo-mngr,fetch,mc_utils,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -h $(FBOUTDIR)/bsp/mc_utils ]; then \
	     ln -s $(BSPDIR)/mc_utils $(FBOUTDIR)/bsp/mc_utils; \
	 fi && \
	 $(MAKE) -C mc_utils/config && \
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



dp_firmware_cadence:
	@if [ ! -d $(BSPDIR)/dp_firmware_cadence ]; then \
	     mkdir -p $(BSPDIR) && cd $(BSPDIR) && \
             wget -q $(dp_firmware_cadence_url) -O dp_firmware_cadence.bin && \
	     chmod +x dp_firmware_cadence.bin && \
             ./dp_firmware_cadence.bin --auto-accept && \
	     mv firmware-cadence-* dp_firmware_cadence && \
	     rm -f dp_firmware_cadence.bin; \
         fi && \
	 if [ ! -L $(FBOUTDIR)/bsp/dp_firmware_cadence ]; then \
	     ln -sf $(BSPDIR)/dp_firmware_cadence $(FBOUTDIR)/bsp/dp_firmware_cadence; \
	 fi && \
	 $(call fbprint_d,"dp_firmware_cadence")



mc_bin:
	@$(call repo-mngr,fetch,mc_bin,bsp) && \
	 cd $(BSPDIR) && \
	 if [ ! -h $(FBOUTDIR)/bsp/mc_bin ]; then \
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
	 $(call repo-mngr,fetch,atf,bsp) && \
	 if [ ! -f $(BSPDIR)/atf/tools/fiptool/fiptool ]; then \
	     $(MAKE) -C $(BSPDIR)/atf fiptool; \
	 fi && \
	 if [ ! -f $(FBOUTDIR)/bsp/ddr_phy_bin/fip_ddr_all.bin ]; then \
	     ln -sf $(BSPDIR)/ddr_phy_bin $(FBOUTDIR)/bsp/ddr_phy_bin; \
	     cd $(BSPDIR)/ddr_phy_bin/lx2160a && $(BSPDIR)/atf/tools/fiptool/fiptool create \
	     --ddr-immem-udimm-1d ddr4_pmu_train_imem.bin \
	     --ddr-immem-udimm-2d ddr4_2d_pmu_train_imem.bin \
	     --ddr-dmmem-udimm-1d ddr4_pmu_train_dmem.bin \
	     --ddr-dmmem-udimm-2d ddr4_2d_pmu_train_dmem.bin \
	     --ddr-immem-rdimm-1d ddr4_rdimm_pmu_train_imem.bin \
	     --ddr-immem-rdimm-2d ddr4_rdimm2d_pmu_train_imem.bin \
	     --ddr-dmmem-rdimm-1d ddr4_rdimm_pmu_train_dmem.bin \
	     --ddr-dmmem-rdimm-2d ddr4_rdimm2d_pmu_train_dmem.bin \
	     $(FBOUTDIR)/bsp/ddr_phy_bin/fip_ddr_all.bin && \
	     cp -f *.bin $(BSPDIR)/atf/; \
	 fi && \
	 $(call fbprint_d,"ddr_phy_bin")
