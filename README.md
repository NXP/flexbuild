## FlexBuild Overview
---------------------
FlexBuild is a component-oriented lightweight build system with capabilities
of flexible, ease-to-use, scalable system build and distro deployment.

Users can use flexbuild to easily build Debian-based RootFS, linux kernel, BSP
components and miscellaneous userspace applications (e.g. graphics, multimedia,
networking, connectivity, security, AI/ML, etc) against Debian-based library
dependencies to streamline the system build with efficient CI/CD.

With flex-installer, users also can easily install various distro to target storage
device (SD/eMMC card or USB/SATA disk) on target board or on host machine.


## Build Environment
--------------------
- Cross-build on x86 host machine running Debian 12 or Ubuntu 22.04
- Native-build on ARM board running Debian
- Build in Docker container hosted on any machine running any distro


## Supported distro for target arm64
------------------------------------------
- Debian-based userland    (base, desktop, server)
- Yocto-based userland     (tiny, devel)
- Buildroot-based userland (tiny, devel)


## Supported platforms
----------------------
- __iMX platform__:  
imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk, imx8mpevk,  
imx8mqevk, imx8qmmek, imx8qxpmek, imx8ulpevk, imx93evk, etc

- __Layerscape platform__:  
ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy,  
ls1088ardb, ls2088ardb, ls2160ardb, lx2162aqds, etc


## FlexBuild Usage
------------------

```
$ cd flexbuild
$ source setup.env
$ bld -h

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
 bld fw -m imx8mpevk             # generate composite firmware (including atf, u-boot, optee_os, kernel, dtb, peripheral firmware, tiny rootfs)
 bld rfs -r debian:desktop       # generate Debian-based desktop rootfs  (with more graphics/multimedia packages for Desktop)
 bld rfs -r debian:server        # generate Debian-based server rootfs   (with more server related packages, no GUI Desktop)
 bld rfs -r debian:base          # generate Debian-based base rootfs     (small footprint with base packages)
 bld rfs -r poky:tiny            # generate poky-based arm64 tiny rootfs
 bld rfs -r buildroot:tiny       # generate Buildroot-based arm64 tiny rootfs
 bld itb -r debian:base          # generate sdk_debian_base_IMX_arm64.itb including kernel, dtb and rootfs_debian_base_arm64.cpio.gz
 bld linux [ -p IMX|LS]          # compile linux kernel for all arm64 IMX or LS machines
 bld atf -m lx2160rdb -b sd      # compile atf image for SD boot on lx2160ardb
 bld boot [ -p IMX|LS ]          # generate boot partition tarball (including kernel,dtb,modules,distro bootscript) for iMX/LS machines
 bld apps -r debian:server -p LS # compile NXP-specific apps against the library dependencies of Debian server rootfs for LS machines
 bld merge-apps                  # merge NXP-specific apps into target Debian rootfs
 bld packrfs                     # pack and compress target rootfs as rootfs_xx.tar.zst
 bld packapps                    # pack and compress target app components as app_components_xx.tar.zst
 bld repo-fetch [ <component> ]  # fetch git repository of all or specified component from remote repos if not exist locally
 bld docker                      # create or attach docker container to build in docker
 bld clean                       # clean all obsolete firmware/linux/apps image except distro rootfs
 bld clean-rfs -r debian:server  # clean target debian-based server arm64 rootfs
 bld clean-bsp                   # clean obsolete bsp image
 bld clean-linux                 # clean obsolete linux image
 bld list                        # list enabled machines and supported various components
```

## More info
------------
Please refer to [flexbuild_usage](docs/flexbuild_usage.md), [build_and_deploy_distro](docs/build_and_deploy_distro.md), [nxp_linux_sdk](docs/nxp_linux_sdk.md) for detailed information.
