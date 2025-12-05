## FlexBuild Overview
---------------------
FlexBuild is a component-oriented lightweight build system and integration platform with
capabilities of flexible, ease-to-use, scalable system build and distro deployment.

Users can use flexbuild to easily build Debian-based RootFS, linux kernel, BSP
components and miscellaneous userspace applications (e.g. graphics, multimedia,
networking, connectivity, security, AI/ML, robotics, etc) against Debian-based library
dependencies to streamline the system build with efficient CI/CD.

With flex-installer, users also can easily install various distro to target storage
device (SD/eMMC card or USB/SATA disk) on target board or on host machine.


## Build Environment
--------------------
- Cross-build in Debian Docker container hosted on x86 Ubuntu or any other distro for arm64 target
- Cross-build on x86 host machine running Debian 13 for arm64 target
- Native-build on ARM board running Debian for arm64 target

## Host system requirement
- Docker hosted on Ubuntu LTS host (e.g. 22.04, 24.04) or other any distro
  Refer to [docker-setup](docs/FAQ-docker-setup.md)
  User can run 'bld docker' to create a Debian docker and build it in docker.
- Debian 12 host
  Refer to [host_requirement](docs/host_requirement.md)


## Supported distro for target arm64
------------------------------------------
- Debian-based userland


## Supported platforms
----------------------
- __iMX platform__:  
imx8mmevk, imx8mpevk, imx8mpfrdm, imx93evk, imx93frdm, imx91evk, imx91frdm, imx91sfrdm, imx95evk, imx95frdm

- __Layerscape platform__:  
ls1028ardb, ls1043ardb, ls1046ardb, lx2160ardb


## Flexbuild Usage
------------------

```
$ cd flexbuild
$ . setup.env  (in host environment)
$ bld docker   (create or attach to docker)
$ . setup.env  (in docker environment)
$ bld host-dep (install host dependent packages)

Usage: bld -m <machine>
   or  bld <target> [ <option> ]
```

Most used example with automated build:
```
Most used example with automated build:
 bld -m imx8mpevk                # automatically build BSP + kernel + NXP-specific components + Debian RootFS for imx8mpevk platform
 bld -m lx2160ardb               # same as above, for lx2160ardb platform
```

Most used example with separate command:
```
 bld bsp -m <machine>             # generate BSP composite firmware (including atf/u-boot/kernel/dtb/peripheral-firmware/initramfs) for <machine>
 bld atf -m <machine> -b sd      # compile atf image for SD boot on <machine>
 bld boot -m <machine>           # generate boot partition tarball (including kernel,dtb,modules,distro bootscript) for <machine>
 bld linux -m <machine>          # compile linux kernel for <machine>

 bld apps -m <machine>           # compile NXP-specific components against the runtime dependencies for <machine>
 bld merge-apps -m <machine>     # merge NXP-specific components into <machine> Debian rootfs

 bld rfs -m <machine>            # generate Debian-based rootfs for <machine>
 bld packrfs -m <machine>        # pack and compress target rootfs as rootfs_<distro_version>_debian_<machine>_arm64.tar.zst

 bld clean-bsp                   # clean obsolete BSP (u-boot/atf/firmware) images
 bld clean-linux                 # clean obsolete linux image
 bld clean-apps -m <machine>     # clean the obsolete <machine>-specific apps components binary images
 bld clean -m <machine>          # equal to "bld clean bsp" + "bld clean linux" + "bld clean-apps -m <machine>"
 bld clean-rfs -m <machine>      # clean target debian-based rootfs for <machine>

 bld docker                      # create or attach docker container to build in docker
 bld list                        # list enabled machines and supported various components
 bld host-dep                    # automatically install the depended deb packages on host
```

## More info
------------
Please refer to https://nxp.com/nxpdebian for more information about NXP Debian Linux SDK Distribution.
[Debian Linux SDK User's Guide]((https://docs.nxp.com/bundle/UG10155).

[flexbuild_usage](docs/flexbuild_usage.md), [build_and_deploy_distro](docs/build_and_deploy_distro.md), [nxp_linux_sdk](docs/nxp_linux_sdk.md) for detailed information.
