NXP Linux SDK for iMX and Layerscape can be built using flex-builder and be deployed using flex-installer or uuu easily.


## How to automatically build all images for single board
```
$ cd flexbuild
$ source setup.env
$ bld -m <machine>

The supported iMX <machine>:
    imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk, imx8mpevk,
    imx8mqevk, imx8qmmek, imx8qxpmek, imx8ulpevk, etc

The supported Layerscape <machine>:
    ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy,
    ls1088ardb_pb, ls2088ardb, ls2160ardb_rev2, lx2162aqds, etc
e.g.
$ bld -m imx8mpevk   # automatically build all images (bootloader, linux, app components, distro userland, etc) for imx8mpevk
$ bld -m ls1046ardb  # automatically build all images (bootloader, linux, app components, distro userland, etc) for ls1046ardb
```


## How to build composite firmware
The iMX/Layerscape composite firmware consists of atf, u-boot, optee_os, kernel, dtb, peripheral firmware, initramfs, etc.
```
Usage: bld -i mkfw -m <machine> [-b <boottype>]
Example:
$ bld -i mkfw -m imx8mpevk      # generate firmware_imx8mpevk_sdboot_lpddr4.img and firmware_imx8mpevk_sdboot_ddr4.img
$ bld -i mkfw -m ls1046ardb     # generate firmware_ls1046ardb_sdboot.img and firmware_ls1046ardb_qspiboot.img
```


## How to deploy distro image using flex-installer
Examples:
- To automatically download and install remote distro image to local storage device
```
$ flex-installer -i auto -d /dev/sdx -m imx8mpevk        (using the default firmware_imx8mpevk_sdboot_lpddr4.img)
or
$ flex-installer -i auto -d /dev/sdx -m imx8mpevk -f firmware_imx8mpevk_sdboot_ddr4.img (using non default image)
```


- To install local distro image
```
$ flex-installer -i pf -d /dev/sdx   (partition and format the target storage device)
$ flex-installer -b boot_LS_arm64_lts_5.10.tgz  -r rootfs_sdk2110_ubuntu_main_arm64.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
or
$ flex-installer -b boot_IMX_arm64_lts_5.10.tgz -r rootfs_sdk2110_ubuntu_desktop_arm64.tgz -f firmware_imx8mpevk_sdboot_lpddr4.img -d /dev/sdx
```


- On ARM board running the TinyLinux, first partition target disk, then download local distro images onto board and install as below
```
$ flex-installer -i pf -d /dev/mmcblk0 (or /dev/sdx)
$ cd /mnt/mmcblk0p3 and download your customized distro images to this partition via wget or scp
$ flex-installer -b <boot> -r <rootfs> -f <firmware> -d <device>
```


- To only download distro image without installation
```
$ flex-installer -i download -m ls1046ardb
```




## How to program SDK composite firmware to SD card or NOR/QSPI/XSPI flash device
- For SD/eMMC card
```
$ wget http://www.nxp.com/lgfiles/sdk/sdk2110/firmware_imx8mpevk_sdboot_lpddr4.img
$ wget http://www.nxp.com/lgfiles/sdk/sdk2110/firmware_ls1046ardb_sdboot.img

Under U-Boot:
Example for imx8mpevk:
=> tftp a0000000 <tftp_dir>/firmware_imx8mpevk_sdboot_lpddr4.img
=> mmc write a0000000 64 1f000

Example for ls1046ardb:
=> tftp a0000000 <tftp_dir>/firmware_ls1046ardb_sdboot.img
=> mmc write a0000000 8 1f000

Under Linux:
Example for using uuu:
$ uuu -b sd firmware_imx8mpevk_sdboot_lpddr4.img firmware_imx8mpevk_sdboot_lpddr4.img
or
$ uuu -b emmc_all imx8ulpevk-flash-singleboot-m33.bin firmware_imx8ulpevk_sdboot.img

Example for using flex-installer:
$ flex-installer -f firmware_imx8mpevk_sdboot_lpddr4.img -d /dev/mmcblk0 -o 32k
$ flex-installer -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0

Example for using dd:
$ sudo dd if=firmware_imx8mpevk_sdboot_lpddr4.img of=/dev/mmcblk0 bs=1k seek=32

$ sudo dd if=<image> of=/dev/mmcblk0 bs=1k seek=<offset>
The <offset> is equal to 4 for Layerscape board and 1/32/33 for iMX board 
```

- For IFC-NOR flash
```
On LS1043ARDB, LS1021ATWR
=> load mmc 0:2 a0000000 firmware_<machine>_uboot_norboot.img
or tftp a0000000 firmware_<machine>_uboot_norboot.img
To program alternate bank:
=> protect off 64000000 +$filesize && erase 64000000 +$filesize && cp.b a0000000 64000000 $filesize
To program current bank
=> protect off 60000000 +$filesize && erase 60000000 +$filesize && cp.b a0000000 60000000 $filesize

On LS2088ARDB:
=> load mmc 0:2 a0000000 firmware_ls2088ardb_uboot_norboot.img
or tftp a0000000 firmware_ls2088ardb_uboot_norboot.img
To program alternate bank:
=> protect off 584000000 +$filesize && erase 584000000 +$filesize && cp.b a0000000 584000000 $filesize
To program current bank:
=> protect off 580000000 +$filesize && erase 580000000 +$filesize && cp.b a0000000 580000000 $filesize
```

- For QSPI-NOR/FlexSPI-NOR flash
```
On LS1012ARDB, LS1028ARDB, LS1046ARDB, LS1088ARDB-PB, LX2160ARDB
=> load mmc 0:2 a0000000 firmware_<machine>_qspiboot.img
or
=> load mmc 0:2 a0000000 firmware_lx2160ardb_xspiboot.img
or tftp a0000000 firmware_<machine>_qspiboot.img
=> sf probe 0:1
=> sf erase 0 +$filesize && sf write 0xa0000000 0 $filesize
```



## How to boot TinyLinux from the composite firmware deployed on SD/eMMC card
For iMX boards:
```
mmc read $loadaddr 0x3000 0x1f000 && bootm $loadaddr#<board_name>
```
For Layerscape boards:
```
=> run sd_bootcmd
or
=> mmc read a0000000 0x8000 0x1f000 && bootm a0000000#<board_name>
```


## How to build composite firmware with non default RCW
Besides modifying RCW settings in configs/board/<machine>/manifest, users also can set
environment variable 'rcw_bin' to override the default RCW as below, for example:
```
$ export rcw_bin=lx2160ardb_rev2/XGGFF_PP_HHHH_RR_19_5_2/rcw_2200_700_3200_19_5_2.bin
$ bld -i clean-bsp
$ bld -i mkfw -m lx2160ardb_rev2
$ unset rcw_bin (unset to avoid impacting the subsequent build)
```
