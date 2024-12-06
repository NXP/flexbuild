NXP Debian Linux SDK for i.MX and Layerscape can be built with Flexbuild and be deployed by flex-installer easily.


## How to automatically build all images for i.MX/Layerscape board
```
$ cd flexbuild
$ . setup.env
$ bld docker (create or attach a docker container)
$ . setup.env
$ bld -m <machine>

The supported iMX <machine>:
    imx93frdm, imx93evk, imx91frdm, imx91evk, imx8mpevk, imx8mmevk, imx8mnevk, imx8mqevk,
    imx8qmmek, imx8qxpmek, imx8ulpevk, etc

The supported Layerscape <machine>:
    ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy,
    ls1088ardb, ls2088ardb, ls2160ardb, lx2162aqds, etc
e.g.
$ bld -m imx93frdm   # automatically build all images (bootloader, linux, app components, Debian RootFS, etc) for imx93frdm
$ bld -m lx2160ardb  # automatically build all images (bootloader, linux, app components, Debian RootFS, etc) for lx2160ardb
```


## How to build BSP composite firmware
The iMX/Layerscape BSP composite firmware consists of atf, u-boot, kernel, dtb, peripheral firmware, initramfs, etc.
```
Usage: bld bsp -m <machine> [-b <boottype>]
Example:
$ bld bsp -m imx93frdm      # generate BSP composite image (firmware_imx93frdm_sdboot.img)
$ bld bsp -m lx2160ardb     # generate BSP composite image (firmware_lx2160ardb_sdboot.img and firmware_lx2160ardb_xspiboot.img)
```


## How to deploy distro image using flex-installer
Examples:
- To automatically download and install remote distro image to local storage device
```
$ flex-installer -i pf -d /dev/mmcblk0      (partition and format SD card, the device name may be /dev/sdX)
$ flex-installer -i auto -d /dev/mmcblk0 -m imx8mpevk (automatically download the prebuilt composite firmware, boot and rootfs images from nxp.com)
```

If you want to install custom images built in Flexbuild by yourself locally, run the command below:
```
$ flex-installer -d <device> -m <machine> -f <firmware> -r <rootfs> -b <boot>
e.g.
$ flex-installer -i pf -d /dev/mmcblk0
$ flex-installer -d /dev/mmcblk0 -m imx93frdm \
		 -f firmware_imx93frdm_sdboot.img \
		 -r rootfs_lsdk2412_debian_server_arm64.tar.zst \
		 -b boot_IMX_arm64_lts_6.6.36.tar.zst
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




## How to flash Linux SDK composite firmware to SD card or NOR/QSPI/XSPI flash device
- For SD/eMMC card
```
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2412/firmware_imx93frm_sdboot.img
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2412/firmware_imx8mpevk_sdboot.img
$ wget http://www.nxp.com/lgfiles/sdk/lsdk2412/firmware_lx2160ardb_sdboot.img

In U-Boot environment:
Example for imx93frdm:
=> tftp a0000000 <tftp_dir>/firmware_imx93frdm_sdboot.img
=> mmc write a0000000 64 1f000

Example for lx2160ardb:
=> tftp a0000000 <tftp_dir>/firmware_lx2160ardb_sdboot.img
=> mmc write a0000000 8 1f000

Example for using flex-installer:
$ flex-installer -f firmware_imx93frdm_sdboot.img -d /dev/mmcblk0 -o 32k
$ flex-installer -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0

Example for using dd:
$ sudo dd if=firmware_imx93frdm_sdboot.img of=/dev/mmcblk0 bs=1k seek=32

$ sudo dd if=<image> of=/dev/mmcblk0 bs=1k seek=<offset>
The <offset> is equal to 4 for Layerscape boards and 32(or 33) for various iMX boards
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
$ bld bsp -m lx2160ardb
$ unset rcw_bin (unset to avoid impacting the subsequent build)
```
