#
# Copyright 2018-2023 NXP
#
# SPDX-License-Identifier: BSD-3-Clause
#

grub_url =  git://git.savannah.gnu.org/grub.git
grub_tag = grub-2.12-rc1

grub:
ifeq ($(CONFIG_GRUB),y)
	@$(call fbprint_b,"grub") && \
	 git clone $(grub_url) $(BSPDIR)/grub -b $(grub_tag) && \
	 cd $(BSPDIR)/grub && \
	 ./bootstrap && ./autogen.sh && \
	 ./configure --target=aarch64-linux-gnu && \
	 $(MAKE) && \
	 echo 'configfile ${cmdpath}/grub.cfg' > grub.cfg && \
	 grub-mkstandalone --directory=./grub-core -O arm64-efi -o BOOTAA64.EFI \
	 		   --modules "part_gpt part_msdos" /boot/grub/grub.cfg=./grub.cfg && \
	 mkdir -p $(FBOUTDIR)/bsp/grub && \
	 cp -f BOOTAA64.EFI $(FBOUTDIR)/bsp/grub && \
	 $(call fbprint_d,"grub")
endif
