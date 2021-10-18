## FlexBuild Usage
------------------
```
$ cd flexbuild
$ source setup.env
$ bld -h
```

```
Usage: bld -m <machine>
   or  bld -i <instruction> -c <component> [-r <distro_type>:<distro_scale>] [-a <arch>] [-p <portfolio> ] [-f cfg-file]
```

Most used example with automated build:
```
 bld -m imx8mpevk                 # automatically build all firmware, linux, apps components and distro userland for imx8mpevk
 bld -m ls1046ardb                # automatically build all firmware, linux, apps components and distro userland for ls1046ardb
 bld -i auto -p IMX               # automatically build all firmware, linux, apps components and distro userland for all arm64 i.MX machines
 bld -i auto -p LS                # automatically build all firmware, linux, apps components and distro userland for all arm64 Layerscape machines
```

Most used example with separate command:
```
 bld -i mkfw -m imx8mpevk         # generate composite firmware (including atf, u-boot, optee_os, kernel, dtb, initramfs, etc) for imx8mpevk
 bld -i mkfw -m ls1046ardb        # generate composite firmware (including atf, u-boot, optee_os, kernel, dtb, peripheral firmware, initramfs) for ls1046ardb
 bld -i mkallfw -p IMX|LS         # generate composite firmware for all iMX or LS machines
 bld -i mkrfs -r ubuntu:desktop   # generate Ubuntu-based desktop arm64 userland (with more graphics/multimedia packages)
 bld -i mkrfs -r ubuntu:main      # generate Ubuntu-based main arm64 userland    (with more networking packages)
 bld -i mkrfs -r ubuntu:lite      # generate Ubuntu-based lite arm64 userland    (for small footprint with base packages)
 bld -i mkrfs -r debian:main      # generate Debian-based main arm64 userland
 bld -i mkrfs -r yocto:tiny       # generate Yocto-based arm64 tiny userland
 bld -i mkrfs -r buildroot:tiny   # generate Buildroot-based arm64 tiny userland
 bld -i mkrfs -r centos           # generate CentOS-based arm64 userland
 bld -i mkitb -r yocto:tiny       # generate sdk_yocto_tiny_IMX_arm64.itb including kernel, DTBs and rootfs_yocto_tiny_arm64.cpio.gz
 bld -c <component>               # compile <component> or <subsystem> (e.g. linux, dpdk, xserver, networking, graphics, multimedia, security, eiq, etc)
 bld -c linux                     # compile linux kernel for all arm64 machines, equivalent to "bld -i compile -c linux -p IMX -a arm64" by default
 bld -c atf -m ls1046ardb -b sd   # compile atf image for SD boot on LS1046ardb
 bld -i mkboot -p IMX|LS          # generate boot partition tarball (including kernel, dtb, modules, distro boot script, etc) for all iMX or LS machines
 bld -i merge-component           # merge component packages into target arm64 userland
 bld -i packrfs -r ubuntu:main    # pack and compress target rootfs as rootfs_<sdk_version>_ubuntu_main_arm64.tgz
 bld -i packapp -r ubuntu:main    # pack and compress target app components as app_components_arm64_ubuntu_main.tgz
 bld -i repo-fetch                # fetch all git repositories of components from remote repos if not exist locally
 bld -i repo-update               # update all components to the latest TOP commmits of current branches
 bld -i mkdistroscr -m ls1046ardb # generate distro boot script for ls1046ardb
 bld docker                       # create or attach Ubuntu docker container to build in docker
 bld clean                        # clean all obsolete firmware/linux/apps image except distro rootfs
 bld clean-rfs -r ubuntu:main     # clean target arm64 ubuntu-based main rootfs
 bld clean-bsp                    # clean obsolete bsp image
 bld clean-linux                  # clean obsolete linux image
 bld list                         # list enabled machines and supported various components
```

The supported options:
```
  -m, --machine         target machine, supports imx6qsabresd, imx7ulpevk, imx8mpevk, imx8mqevk, imx8mmevk, imx8mnevk, imx8qmmek, imx8qxpmek,
                        ls1012ardb, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1088ardb_pb, ls2088ardb, lx2160ardb_rev2, lx2162aqds, etc
  -c, --component       component or subsystem to be built: linux, uboot, atf, networking, graphics, multimedia, security, eiq, dpdk, armnn, tflite, etc
  -b, --boottype        type of boot media, valid argument: sd, emmc, qspi, xspi, nor, nand, default all types if unspecified
  -i, --instruction     instruction to do for dedicated purpose, valid argument as below:
      mkfw              generate composite firmware (contains atf, u-boot, peripheral firmware, kernel, dtb, tinylinux rootfs, etc)
      mkallfw           generate composite firmware for all platforms
      mkitb             generate <sdk_version>_<distro_type>_<distro_scale>_<portfolio>_<arch>.itb
      mkboot            generate boot partition tarball (contains kernel, modules, dtb, distro boot script, secure boot header, etc)
      mkrfs             generate target rootfs, associated with -r, -a and -p options for different distro type and architecture
      mkdistroscr       generate distro autoboot script for all or single machine
      mkflashscr        generate U-Boot script of flashing images for all machines
      signimg           sign various images and generate secure boot header for the specified machine
      merge-component   merge custom component packages and kernel modules into target distro rootfs
      auto              automatically build all firmware, kernel, apps components and distro userland
      clean             clean all the obsolete images except distro rootfs
      clean-firmware    clean obsolete firmware images generated in build/firmware directory
      clean-linux       clean obsolete linux images generated in build/linux directory
      clean-apps        clean obsolete apps images
      clean-rfs         clean target rootfs
      packrfs           pack and compress distro rootfs as .tgz
      packapps          pack and compress apps components as .tgz
      repo-fetch        fetch single or all git repositories if not exist locally
      repo-branch       set single or all git repositories to specified branch
      repo-update       update single or all git repositories to latest HEAD
      repo-commit       set single or all git repositories to specified commit
      repo-tag          set single or all git repositories to specified tag
      rfsraw2ext        convert raw rootfs to ext4 rootfs
      list              list enabled config, machines and components
  -a, --arch            target arch of processor, valid argument: arm64 and arm32 (the default is arm64)
  -p, --portfolio       specify portfolio of SoC, valid argument: LS or IMX
  -f, --cfgfile         specify config file, configs/sdk.yml is used by default if only the file exists
  -r, --rootfs          specify flavor of target rootfs, valid argument: ubuntu|debian|centos|yocto|buildroot:main|desktop|devel|lite|tiny
  -j, --jobs            number of parallel build jobs, default 16 jobs if unspecified
  -s, --secure          enable security feature in case of secure boot without IMA/EVM
  -t, --ima-evm         enable IMA/EVM feature in case of secure boot with IMA/EVM
  -T, --cot             specify COT (Chain of Trust) type for secure boot, valid argument: arm-cot, arm-cot-with-verified-boot, nxp-cot
  -e, --encapsulation   enable encapsulation and decapsulation feature for chain of trust with confidentiality in case secure boot
  -B, --buildarg        secondary argument for various build commands
  -F, --force           force build regardless of the default configuration
  -v, --version         print the version of flexbuild
  -h, --help            print help info
```



## How to build composite firmware
----------------------------------
The composite firmware consists of RCW/PBL, ATF BL2, ATF BL31, BL32 OPTEE, BL33 U-Boot/UEFI, bootloader environment variables,
secure boot headers, Ethernet firmware, dtb, kernel and tiny initrd rootfs, etc, this composite firmware can be programmed at
offset 0x0 in NOR/QSPI/FlexSPI flash device or at offset 4k (LS) or 1k/32k/33k (I.MX) in SD/eMMC card.
```
Usage: bld -i mkfw -m <machine> [-b <boottype>]
Example:
$ bld -i mkfw -m ls1046ardb        # generate all boot types composite firmware_ls1046ardb_<boottype>.img
$ bld -i mkfw -m ls1046ardb -b sd  # generate specified boot type composite firmware_ls1046ardb_sdboot.img
$ bld -i mkfw -m imx6qsabresd      # generate composite firmware_imx6qsabresd_sdboot.img
$ bld -i mkfw -m imx8mpevk         # generate composite firmware_imx8mpevk_sdboot.img
```


## How to build boot partition tarball
--------------------------------------
```
Usage: bld -i <instruction> [ -p <portfolio> ] [ -a <arch> ]
Examples:
$ bld -i mkboot -p LS             # generate boot_LS_arm64_lts_5.10.tgz for arm64 Layerscape platforms
$ bld -i mkboot -a arm32          # generate boot_LS_arm32_lts_5.10.tgz for arm32 Layerscape platforms
$ bld -i mkboot -p IMX            # generate boot_IMX_arm64_lts_5.10.tgz for arm64 iMX platforms
$ bld -i mkboot -p IMX -a arm32   # generate boot_IMX_arm32_lts_5.10.tgz for arm32 iMX platforms
```


## How to build linux itb FIT image
-----------------------------------
```
$ bld -i mkitb -r yocto:tiny -p LS    # generate Yocto-based tiny <sdk_version>_yocto_tiny_LS_arm64.itb
$ bld -i mkitb -r ubuntu:lite -p LS   # generate Ubuntu-based lite <sdk_version>_ubuntu_lite_LS_arm64.itb
$ bld -i mkitb -r yocto:tiny -p IMX   # generate Yocto-based tiny <sdk_version>_yocto_tiny_IMX_arm64.itb
$ bld -i mkitb -r ubuntu:lite -p IMX  # generate Ubuntu-based lite <sdk_version>_ubuntu_lite_IMX_arm64.itb
```


## How to build Linux kernel and modules
----------------------------------------
To build linux with default repo and current branch according to default config
```
Usage: bld -c linux [ -a <arch> ] [ -p <portfolio> ]
Examples:
$ bld -c linux                        # for arm64 i.MX platforms ('-a arm64 -p IMX' by default)
$ bld -c linux -a arm32               # for arm32 i.MX platforms
$ bld -c linux -p LS                  # for arm64 Layerscape platforms
$ bld -c linux -a arm32 -p LS         # for arm32 Layerscape platforms
```

To build linux with the specified kernel repo and branch/tag according to default kernel config
```
Usage: bld -c linux:<kernel_repo>:<branch|tag|commit> [ -a <arch> ]
Examples:
$ bld -c linux:linux-lts-nxp:lf-5.10.y
$ bld -c linux:linux:LSDK-21.08
```

To customize kernel options with the default repo and current branch in interactive menu
```
$ bld -c linux:custom                 # generate a customized .config
$ bld -c linux                        # compile kernel and modules according to the generated .config above
```

To build custom linux with the specified kernel repo and branch/tag according to default config and the appended fragment config
```
Usage: bld -c linux [ :<kernel_repo>:<tag|branch> ] -B fragment:<xx.config> [ -a <arch> ]
Examples:
$ bld -c linux -B fragment:ima_evm_arm64.config
$ bld -c linux -B fragment:"ima_evm_arm64.config lttng.config"
$ bld -c linux:linux:LSDK-21.08 -B fragment:lttng.config
```




## How to build ATF (TF-A)
--------------------------
```
Usage: bld -c atf [ -m <machine> ] [ -b <boottype> ] [ -s ] [ -B bootloader ]
Examples:
$ bld -c atf -m ls1028ardb -b sd             # build U-Boot based ATF image for SD boot on ls1028ardb
$ bld -c atf -m ls1046ardb -b qspi           # build U-Boot based ATF image for QSPI boot on ls1046ardb
$ bld -c atf -m ls2088ardb -b nor -s         # build U-Boot based ATF image for secure IFC-NOR boot on ls2088ardb
$ bld -c atf -m lx2160ardb -b xspi -B uefi   # build UEFI based ATF image for FlexSPI-NOR boot on lx2160ardb
$ bld -c atf -m imx8mpevk -b sd              # build U-Boot based ATF image for SD boot on imx8mpevk
```
bld can automatically build the dependent RCW, U-Boot/UEFI, OPTEE and CST before building ATF to generate target images.
Note 1: If you want to specify different RCW configuration instead of the default one, firstly modify variable rcw_<boottype> in
        configs/board/\<machine\>/manifest, then run 'bld -c rcw -m <machine>' to generate new RCW image.
Note 2: The '-s' option is used for secure boot, FUSE_PROVISIONING are not enabled by default, you can change
        CONFIG_FUSE_PROVISIONING:n to y in configs/sdk.yml to enable it if needed.



## How to build U-Boot
----------------------
```
Usage:   bld -c uboot -m <machine>
Examples:
$ bld -c uboot -m ls2088ardb                 # build U-Boot image for ls2088ardb
$ bld -c uboot -m imx6qsabresd               # build U-Boot image for imx6qsabresd
$ bld -c uboot -m imx8mpevk                  # build U-Boot image for imx8mpevk
```



## How to build various firmware components
-------------------------------------------
```
Usage: bld -c <component> [ -b <boottype> ]
Examples:
$ bld -c rcw -m ls1046ardb                   # build RCW images for ls1046ardb
$ bld -c mc_utils                            # build mc_utils image
$ bld -c layerscape_fw                       # build binary fm_ucode, qe_ucode, mc_bin, phy_cortina, pfe_bin, dp_firmware_cadence, etc
```


## How to build APP components
------------------------------
```
Usage: bld -c <component> [ -a <arch> ] [ -r <distro_type>:<distro_scale> ]
Examples:
$ bld -c apps                                # build all apps components against Ubuntu-based desktop arm64 userland by default
$ bld -c apps -r ubuntu:main                 # build all apps components against Ubuntu-based main arm64 userland
$ bld -c apps -r yocto:devel                 # build apps components against arm64 Yocto-based userland
$ bld -c apps -r buildroot:devel             # build all apps components against arm64 buildroot-based userland
$ bld -c dpdk -r ubuntu:main                 # build DPDK component against Ubuntu-based main userland
$ bld -c dpdk -r yocto:devel                 # build DPDK component against Yocto devel userland
$ bld -c weston -r ubuntu:desktop            # build weston component against Ubuntu-based desktop userland
$ bld -c xserver                             # build xserver component against Ubuntu-based desktop userland
$ bld -c imx_gst1.0_plugin                   # build iMX gstreamer1.0 plugins component against Ubuntu-based desktop userland
$ bld -c tflite                              # build tensorflow lite against Ubuntu-based desktop userland by default
$ bld -c armnn                               # build armNN against Ubuntu-based desktop userland by default
$ bld -c eiq                                 # build all eIQ components
(note: '-r ubuntu:desktop -a arm64 -p IMX' is the default if unspecified)
```




## Manage git repositories of various components
------------------------------------------------
```
Examples:
$ bld -i repo-fetch                          # git clone source repositories of all components
$ bld -i repo-fetch -c dpdk                  # git clone source repository for single DPDK component
$ bld -i repo-branch                         # switch branches of all components to specified branches according to the config file
$ bld -i repo-tag                            # switch tags of all components to specified tags according to default config
$ bld -i repo-commit                         # set all components to the specified commmits of current branches
$ bld -i repo-update                         # update all components to the latest HEAD commmit of current branches 
```



## How to use different build config instead of the default config
------------------------------------------------------------------
User can create a custom config file configs/custom.yml, flex-builder will preferentially select custom.yml, otherwise, if
there is a config file configs/sdk_internal.yml, it will be used. In case there is only configs/sdk.yml, it will be used.
If there are multiple config files in configs directory, user can specify the expected one by specifying '-f <cfg>' option.
Example:
```
$ bld -m ls1043ardb -f custom.yml
$ bld -m ls1028ardb -f test.yml
$ bld -m imx8mpevk -f sdk.yml
```



## How to change the default component download path and build output path
--------------------------------------------------------------------------
The default components download path is <flexbuild_dir>/components, the default build output path is <flexbuild_dir>/build.
There are two ways to change the default path:  
- Way1: set PKGDIR and/or FBOUTDIR in environment variable as below:
```
$ export PKGDIR=<path>
$ export FBOUTDIR=<path>
```
- Way2: modify DEFAULT_PKGDIR and/or DEFAULT_OUT_PATH in <flexbuild_dir>/configs/sdk.yml
