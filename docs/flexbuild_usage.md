## FlexBuild Usage
------------------
```
$ cd flexbuild
$ . setup.env  (in host environment)
$ bld docker   (create or attach to docker)
$ . setup.env  (in docker environment)
$ bld host-dep (install host dependent packages)
```

```
Usage: bld -m <machine>
   or  bld <target> [ <option> ]
```

Most used example with automated build:
```
 bld -m imx8mpevk                # automatically build BSP + kernel + NXP-specific apps + Debian RootFS for imx8mpevk platform
 bld -m lx2160ardb               # same as above, for lx2160ardb platform
 bld auto -p IMX (or -p LS)      # same as above, for all arm64 iMX (or Layerscape) platforms
```

Most used example with separate command:
```
 bld bsp -m imx93frdm            # generate BSP composite firmware (including atf/u-boot/kernel/dtb/peripheral-firmware/initramfs) for single machine
 bld bspall [ -p IMX|LS ]        # generate BSP composite firmware for all i.MX or LS machines
 bld rfs [ -r debian:desktop ]   # generate Debian-based Desktop rootfs  (with more graphics/multimedia packages for Desktop)
 bld rfs -r debian:server        # generate Debian-based Server rootfs   (with more server related packages, no GUI Desktop)
 bld rfs -r debian:base          # generate Debian-based base rootfs     (small footprint with base packages)
 bld rfs -r poky:tiny            # generate poky-based arm64 tiny rootfs
 bld rfs -r buildroot:tiny       # generate Buildroot-based arm64 tiny rootfs
 bld itb -r poky:tiny            # generate poky_tiny_IMX_arm64.itb including kernel, dtb and rootfs_poky_tiny_arm64.cpio.gz
 bld linux [ -p IMX|LS]          # compile linux kernel for all arm64 IMX or LS machines
 bld atf -m lx2160rdb -b sd      # compile atf image for SD boot on lx2160ardb
 bld boot [ -p IMX|LS ]          # generate boot partition tarball (including kernel,dtb,modules,distro bootscript) for iMX/LS machines
 bld apps                        # compile NXP-specific components against the runtime dependencies of Debian Desktop rootfs for i.MX machines
 bld apps -r debian:server -p LS # compile NXP-specific components against the runtime dependencies of Debian Server rootfs for LS machines
 bld ml [ -r <type> ]            # compile NXP-specific eIQ AI/ML components against the library dependencies of Debian rootfs
 bld merge-apps [ -r <type> ]    # merge NXP-specific components into target Debian rootfs (Desktop by default,add '-r debian:server' for Server)
 bld packrfs [ -r <type> ]       # pack and compress target rootfs as rootfs_xx.tar.zst (or add '-r debian:server' for Server)
 bld packapps [ -r <type> ]      # pack and compress target app components as apps_xx.tar.zst (add '-p LS' for Layerscape platforms)
 bld repo-fetch [ <component> ]  # fetch git repository of all or specified component from remote repos if not exist locally
 bld docker                      # create or attach docker container to build in docker
 bld clean                       # clean all obsolete firmware/linux/apps binary images except distro rootfs
 bld clean-apps [ -r <type> ]    # clean the obsolete NXP-specific apps components binary images
 bld clean-rfs [ -r <type> ]     # clean target debian-based server arm64 rootfs
 bld clean-bsp                   # clean obsolete BSP (u-boot/atf/firmware) images
 bld clean-linux                 # clean obsolete linux image
 bld list                        # list enabled machines and supported various components
 bld host-dep                    # automatically install the depended deb packages on host

```

The supported options:
```
  -m, --machine         target machine, supports imx6qsabresd, imx7ulpevk, imx8mpevk, imx8mqevk, imx8mmevk, imx8mnevk, imx8qmmek, imx8qxpmek,
                        ls1012ardb, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1088ardb, ls2088ardb, lx2160ardb, lx2162aqds, etc
  -b, --boottype        type of boot media, valid argument: sd, emmc, qspi, xspi, nor, nand, default all types if unspecified
  -a, --arch            target arch of processor, valid argument: arm64 and arm32 (the default is arm64)
  -p, --portfolio       specify portfolio of SoC, valid argument: LS or IMX
  -f, --cfgfile         specify config file, configs/sdk.yml is used by default if only the file exists
  -r, --rootfs          specify flavor of target rootfs, valid argument: debian|poky|buildroot:base|desktop|server|tiny
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
The supported object commands:
```
  bsp               generate BSP composite firmware (contains atf, u-boot, peripheral firmware, kernel, dtb, tinylinux rootfs, etc)
  bspall            generate BSP composite firmware for all platforms
  itb               generate <sdk_version>_<distro_type>_<distro_scale>_<portfolio>_<arch>.itb
  boot              generate boot partition tarball (contains kernel, modules, dtb, distro boot script, secure boot header, etc)
  rfs               generate target rootfs, associated with -r, -a and -p options for different distro type and architecture
  distroscr         generate distro autoboot script for all or single machine
  flashscr          generate U-Boot script of flashing images for all machines
  signimg           sign various images and generate secure boot header for the specified machine
  merge-apps        merge NXP-specific apps components into target distro rootfs
  auto              automatically build all bsp, kernel, apps components and distro userland
  clean             clean all the obsolete images except distro rootfs
  clean-firmware    clean obsolete firmware images generated in build/firmware directory
  clean-linux       clean obsolete linux images generated in build/linux directory
  clean-apps        clean obsolete apps images
  clean-rfs         clean target rootfs
  packrfs           pack and compress distro rootfs as .tar.zst
  packapps          pack and compress apps components as .tar.zst
  repo-fetch        fetch single or all git repositories if not exist locally
  repo-branch       set single or all git repositories to specified branch
  repo-update       update single or all git repositories to latest HEAD
  repo-commit       set single or all git repositories to specified commit
  repo-tag          set single or all git repositories to specified tag
  rfsraw2ext        convert raw rootfs to ext4 rootfs
  list              list enabled config, machines and components
```



## How to build composite firmware
----------------------------------
The composite firmware consists of ATF BL2, ATF BL31, BL32 OPTEE, BL33 U-Boot/UEFI, bootloader environment variables,
secure boot headers, Ethernet firmware, dtb, kernel and tiny initrd rootfs, etc, this composite firmware can be programmed
at offset 0x0 in NOR/QSPI/FlexSPI flash device or at offset 4k (LS) or 1k/32k/33k (I.MX) in SD/eMMC card.
```
Usage: bld bsp -m <machine> [-b <boottype>]
Example:
$ bld bsp -m imx8mpevk         # generate composite firmware_imx8mpevk_sdboot.img
$ bld bsp -m imx93frdm         # generate composite firmware_imx93frdm_sdboot.img
$ bld bsp -m ls1046ardb        # generate composite firmware_ls1046ardb_<boottype>.img
$ bld bsp -m lx2160ardb        # generate composite firmware_lx2160ardb_<boottype>.img
```


## How to build boot partition tarball
--------------------------------------
```
Usage: bld <instruction> [ -p <portfolio> ] [ -a <arch> ]
Examples:
$ bld boot                    # generate boot_IMX_arm64_lts_xx.tar.zst for arm64 i.MX platforms by default
$ bld boot -a arm32           # generate boot_IMX_arm32_lts_xx.tar.zst for arm32 i.MX platforms
$ bld boot -p LS              # generate boot_LS_arm64_lts_xx.tar.zst for arm64 Layerscape platforms
$ bld boot -p LS -a arm32     # generate boot_LS_arm32_lts_xx.tar.zst for arm32 iMX platforms
```


## How to build linux itb FIT image
-----------------------------------
```
$ bld itb -r poky:tiny -p IMX   # generate Yocto-based tiny <sdk_version>_poky_tiny_IMX_arm64.itb
$ bld itb -r debian:base -p IMX # generate Debian-based base <sdk_version>_debian_base_IMX_arm64.itb
$ bld itb -r poky:tiny -p LS    # generate Yocto-based tiny <sdk_version>_poky_tiny_LS_arm64.itb
$ bld itb -r debian:base -p LS  # generate Debian-based base <sdk_version>_debian_base_LS_arm64.itb
```


## How to build Linux kernel and modules
----------------------------------------
To build linux with default repo and current branch according to default config
```
Usage: bld linux [ -a <arch> ] [ -p <portfolio> ]
Examples:
$ bld linux                        # for arm64 i.MX platforms ('-a arm64 -p IMX' by default)
$ bld linux -a arm32               # for arm32 i.MX platforms
$ bld linux -p LS                  # for arm64 Layerscape platforms
$ bld linux -a arm32 -p LS         # for arm32 Layerscape platforms
```

To build linux with the specified kernel repo and branch/tag according to default kernel config
```
Usage: bld linux:<kernel_repo>:<branch|tag|commit> [ -a <arch> ]
Examples:
$ bld linux:linux-lts-nxp:lf-6.1.36
$ bld linux:linux:LSDK-21.08
```

To build a customized kernel image with menuconfig
```
$ bld linux:menuconfig             # generate a customized .config by changing kernel options in menuconfig
$ bld linux                        # compile kernel and modules according to the newly generated .config above
```

To build custom linux with the default kernel config and the appended fragment config specified in configs/linux directory
```
Usage: bld linux -B fragment:<xx.config> [ -a <arch> ] [ -p LS|IMX ]
Examples:
$ bld linux -B fragment:ima_evm_arm64.config
$ bld linux -B fragment:"ima_evm_arm64.config lttng.config"
```




## How to build ATF (TF-A)
--------------------------
```
Usage: bld atf [ -m <machine> ] [ -b <boottype> ] [ -s ] [ -B bootloader ]
Examples:
$ bld atf -m imx8mpevk             # build ATF image for SD boot on imx8mpevk
$ bld atf -m ls1046ardb -b qspi    # build ATF image for QSPI boot on ls1046ardb
$ bld atf -m lx2160ardb -b sd      # build ATF image for SD boot on lx2160ardb
$ bld atf -m lx2160ardb -b xspi    # build ATF image for FlexSPI-NOR boot on lx2160ardb
```
bld can automatically build the dependent RCW, U-Boot/UEFI, OPTEE and CST before building ATF to generate target images.
Note: If you want to specify different RCW configuration instead of the default one, firstly modify variable rcw_<boottype> in
      configs/board/\<machine\>.conf, then run 'bld rcw -m <machine>' to generate new RCW image.



## How to build U-Boot
----------------------
```
Usage:   bld uboot -m <machine>
Examples:
$ bld uboot -m imx8mpevk       # build U-Boot image for imx8mpevk
$ bld uboot -m imx93frwy       # build U-Boot image for imx93frwy
$ bld uboot -m ls1046ardb      # build U-Boot image for ls1046ardb
```



## How to build various firmware components
-------------------------------------------
```
Usage: bld <component> [ -b <boottype> ]
Examples:
$ bld rcw -m ls1046ardb        # build RCW images for ls1046ardb
$ bld mc_utils                 # build mc_utils image for DPAA2 on Layerscape platform
$ bld layerscape_fw            # build binary fm_ucode, qe_ucode, mc_bin, phy_cortina, pfe_bin, dp_firmware_cadence, etc
$ bld mcore_demo               # build imx m-core demo
```


## How to build APP components
------------------------------
```
Usage: bld <component> [ -a <arch> ] [ -r <distro_type>:<distro_scale> ]
Examples:
$ bld imx_gst_plugin               # build NXP-specific iMX gstreamer plugins component against Debian-based desktop rootfs
$ bld dpdk -r debian:server        # build NXP-specific DPDK component against Debian-based server rootfs
$ bld apps                         # build NXP-specific apps components against Debian-based desktop rootfs for i.MX platforms
$ bld apps -r debian:server -p LS  # build NXP-specific apps components against Debian-based server rootfs for LS platforms
(note: '-r debian:desktop -a arm64 -p IMX' is the default if unspecified)
```




## Manage git repositories of various components
------------------------------------------------
```
Examples:
$ bld repo-fetch        # git clone source repositories of all components
$ bld repo-fetch dpdk   # git clone source repository for single DPDK component
$ bld repo-branch       # switch branches of all components to specified branches according to the config file
$ bld repo-tag          # switch tags of all components to specified tags according to default config
$ bld repo-commit       # set all components to the specified commmits of current branches
$ bld repo-update       # update all components to the latest HEAD commmit of current branches 
```



## How to use different build config instead of the default config
------------------------------------------------------------------
User can create a custom config file configs/custom.yml, flex-builder will preferentially select custom.yml, otherwise, the
default configs/sdk.yml will be used. If there are multiple config files in configs directory, user can specify the expected
one by specifying '-f <cfg>' option.
Example:
```
$ bld -m imx8mpevk -f sdk.yml
$ bld -m lx2160ardb -f custom.yml
```



## How to change the default path of the downloaded component and build output directory
----------------------------------------------------------------------------------------
The default components download path is <flexbuild_dir>/components, the default build output path is <flexbuild_dir>/build.
There are two ways to change the default path:  
- Way1: set PKGDIR and/or FBOUTDIR in environment variable as below:
```
$ export PKGDIR=<path>
$ export FBOUTDIR=<path>
```
- Way2: modify DEFAULT_PKGDIR and/or DEFAULT_OUT_PATH in <flexbuild_dir>/configs/sdk.yml
