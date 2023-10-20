NXP Linux SDK for iMX and Layerscape can be built via flex-builder and be deployed via flex-installer or uuu easily.


## How to automatically build all images for single board
```
$ cd flexbuild
$ source setup.env
$ bld -m <machine>

The supported iMX <machine>:
    imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk, imx8mpevk,
    imx8mqevk, imx8qmmek, imx8qxpmek, imx8ulpevk, imx93evk, etc

The supported Layerscape <machine>:
    ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy,
    ls1088ardb, ls2088ardb, ls2160ardb, lx2162aqds, etc
e.g.
$ bld -m imx8mpevk   # automatically build all images (bootloader, linux, app components, Debian RootFS, etc) for imx8mpevk
$ bld -m lx2160ardb  # automatically build all images (bootloader, linux, app components, Debian RootFS, etc) for lx2160ardb
```


## How to build composite firmware
The iMX/Layerscape composite firmware consists of atf, u-boot, optee_os, kernel, dtb, peripheral firmware, initramfs, etc.
```
Usage: bld fw -m <machine> [-b <boottype>]
Example:
$ bld fw -m imx8mpevk      # generate firmware_imx8mpevk_sdboot_lpddr4.img and firmware_imx8mpevk_sdboot_ddr4.img
$ bld fw -m lx2160ardb     # generate firmware_lx2160ardb_sdboot.img and firmware_lx2160ardb_xspiboot.img
```


## How to deploy distro image using flex-installer
Examples:
- To automatically download and install remote distro image to local storage device
```
$ flex-installer -i pf -d /dev/mmcblk0   (partition and format SD card, the device name may be /dev/sdx)
$ flex-installer -i auto -d /dev/mmcblk0 -m imx8mpevk   (using the default composite firmware, boot and rootfs images)
or
$ flex-installer -i auto -d /dev/mmcblk0 -m imx8mpevk -f <firmware> -r <rootfs> (using specified image name instead of default)
```


- To install local distro images built by yourself
```
$ flex-installer -i pf -d /dev/sdx
$ flex-installer -m <machine> -d /dev/sdx -f <firmware> -b <boot> -r <rootfs>
e.g.
$ flex-installer -m lx2160ardb -d /dev/sdx -f firmware_lx2160ardb_sdboot.img -b boot_LS_arm64_lts_xx.tar.zst -r rootfs_lsdk_debian_server_arm64.tar.zst
```


- On ARM board running the TinyLinux, firstly format SD card, then download local distro images onto board and install as below
```
$ flex-installer -i pf -d /dev/mmcblk0 (or /dev/sdx)
$ cd /mnt/mmcblk0p2 and download your customized distro images to this partition via wget or scp
$ flex-installer -m <machine> -d <device> -f <firmware> -b <boot> -r <rootfs>
```


- To only download distro image without installation
```
$ flex-installer -i download -m lx2160ardb
```




## How to flash Linux SDK composite firmware to SD card or NOR/QSPI/XSPI flash device in various environment
- For SD/eMMC card
```
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2310/firmware_imx8mpevk_sdboot_lpddr4.img
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2310/firmware_lx2160ardb_sdboot.img

In U-Boot environment:
Example for imx8mpevk:
=> tftp a0000000 <tftp_dir>/firmware_imx8mpevk_sdboot_lpddr4.img
=> mmc write a0000000 64 1f000

Example for lx2160ardb:
=> tftp a0000000 <tftp_dir>/firmware_lx2160ardb_sdboot.img
=> mmc write a0000000 8 1f000

In Linux environment:
Example for using uuu:
$ uuu -b sd flash-lpddr4.bin firmware_imx8mpevk_sdboot_lpddr4.img
or
$ uuu -b emmc_all imx8ulpevk-flash-singleboot-m33.bin firmware_imx8ulpevk_sdboot.img

Example for using flex-installer:
$ flex-installer -f firmware_imx8mpevk_sdboot_lpddr4.img -d /dev/mmcblk0 -o 32k
$ flex-installer -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0

Example for using dd:
$ sudo dd if=firmware_imx8mpevk_sdboot_lpddr4.img of=/dev/mmcblk0 bs=1k seek=32

$ sudo dd if=<image> of=/dev/mmcblk0 bs=1k seek=<offset>
The <offset> is equal to 4 for Layerscape board and 1/32/33 for various iMX board
```

- For IFC-NOR flash
```
On LS1043ARDB, LS1021ATWR
=> tftp a0000000 <tftp_dir>/firmware_ls1043ardb_norboot.img
To program alternate bank:
=> protect off 64000000 +$filesize && erase 64000000 +$filesize && cp.b a0000000 64000000 $filesize
To program current bank
=> protect off 60000000 +$filesize && erase 60000000 +$filesize && cp.b a0000000 60000000 $filesize
```

- For QSPI-NOR/FlexSPI-NOR flash
```
On LX2160ARDB, LS1012ARDB, LS1028ARDB, LS1046ARDB, LS1088ARDB
=> tftp a0000000 <tftp_dir>/firmware_lx2160ardb_qspiboot.img
=> sf probe 0:1
=> sf erase 0 +$filesize && sf write 0xa0000000 0 $filesize
```



## How to flash LSDK composite firmware to SD card in Win10/Win11 environment

If you have no Linux host machine available, you can follow the steps below to flash a composite image to SD card on Windows host.

1. Download the 'etcher' tool (https://etcher.balena.io) and install it on your Windows machine.

2. Create a folder (e.g. C:/LSDK) and download the prebuilt LSDK composite firmware from the links below to this folder, e.g.
```
   http://www.nxp.com/lgfiles/sdk/lsdk2310/sd_pt_32k.img  (or sd_pt_4k.img, sd_pt_33k.img)
   http://www.nxp.com/lgfiles/sdk/lsdk2310/firmware_lx2160ardb_sdboot.img
   http://www.nxp.com/lgfiles/sdk/lsdk2310/firmware_imx8mpevk_sdboot_lpddr4.img
   http://www.nxp.com/lgfiles/sdk/lsdk2310/firmware_imx93evk_sdboot_a1.img
```
   Note: sd_pt_4k.img is used for Layerscape SoC, sd_pt_33k.img for imx8mq and imx8mm SoC, sd_pt_32k.img for all other imx8/imx9 SoC.

3. Run Windows cmd command as below to combine the partition table image with the composite firmware
```
   C:\Windows\System32> cd C:/LSDK
   C:\LSDK>  dir
   C:\LSDK>  copy /b sd_pt_32k.img + firmware_imx8mpevk_sdboot_lpddr4.img firmware_imx8mpevk_sdboot_new.img
```
   The new firmware_imx8mpevk_sdboot_new.img will be generated.

4. Run the etcher tool, choose image file and target disk, then begin flashing the newly generated image to the target SD card.

5. Unplug SD card from Windows host machine and plug it on the target board, set DIP switch for SD boot or run run sd_bootcmd at U-Boot prompt.

6. Log in to TinyLinux as 'root', setup your network on the board and install LSDK Debian distro with the commands below by flex-installer.
```
   $ flex-installer -i pf -d /dev/mmcblkx
   $ flex-installer -i auto -m <machine> -d /dev/mmcblkx -r <rootfs>
```
   The \<rootfs\> can be rootfs_lsdk2310_debian_desktop_arm64.tar.zst, rootfs_lsdk2310_debian_server_arm64.tar.zst or rootfs_lsdk2310_debian_base_arm64.tar.zst)
   The \<machine\> can be imx93evk, imx8mpevk, imx8mqevk, imx8mmevk, imx8ulpevk, imx8mnevk, imx8qmmek, imx8qxpmek, etc
   or lx2160ardb, lx2160aqds, ls1012ardb, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy, ls1088ardb, ls2088ardb, etc




## How to boot TinyLinux from the composite firmware deployed on SD/eMMC card
For iMX boards:
```
=> mmc read $loadaddr 0x4000 0x1f000 && bootm $loadaddr#<board_name>
e.g.
=> setenv tinylinux 'mmc read 0xa0000000 0x4000 0x1f000 && bootm a0000000#imx8mpevk'
=> saveenv
=> run tinylinux
```

For Layerscape boards:
```
=> run sd_bootcmd
or
=> mmc read a0000000 0x8000 0x1f000 && bootm a0000000#<board_name>
e.g.
=> setenv tinylinux 'mmc read a0000000 0x8000 0x1f000 && bootm a0000000#lx2160ardb>'
=> saveenv
=> run tinylinux
```


## How to build composite firmware with non default RCW for Layerscape platform
Besides modifying RCW settings in configs/board/<machine>.conf, users also can set
environment variable 'rcw_bin' to override the default RCW as below, for example:
```
$ export rcw_bin=lx2160ardb/XGGFF_PP_HHHH_RR_19_5_2/rcw_2200_700_3200_19_5_2.bin
$ bld clean-bsp
$ bld fw -m lx2160ardb
$ unset rcw_bin (unset to avoid impacting the subsequent build)
```
