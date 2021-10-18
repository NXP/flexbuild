## FlexBuild Overview
---------------------
FlexBuild is a component-oriented lightweight build framework and integration platform
with capabilities of flexible, ease-to-use, scalable system build and distro deployment.

With flex-builder, users can easily build linux, u-boot, atf and miscellaneous
userspace applications (e.g. networking, graphics, multimedia, security, AI/ML)
and customizable distro root filesystem to streamline the system build with
efficient CI/CD.

With flex-installer, users can easily install various distro to target storage
device (SD/eMMC card or USB/SATA disk) on target board or on host machine.


## Build Environment
--------------------
- Cross-build on x86 host machine running Ubuntu
- Native-build on ARM board running Ubuntu
- Build in Docker container hosted on any machine running any distro


## Supported distro for target arm64/arm32
------------------------------------------
- Ubuntu-based userland    (main, desktop, devel, lite)
- Debian-based userland    (main, desktop, devel, lite)
- CentOS-based userland    (7.9.2009)
- Yocto-based userland     (tiny, devel)
- Buildroot-based userland (tiny, devel)


## Supported platforms
----------------------
- __iMX platform__:  
imx6qpsabresd, imx6qsabresd, imx6sllevk, imx7ulpevk, imx8mmevk, imx8mnevk, imx8mpevk,  
imx8mqevk, imx8qmmek, imx8qxpmek, imx8ulpevk, etc

- __Layerscape platform__:  
ls1012ardb, ls1012afrwy, ls1021atwr, ls1028ardb, ls1043ardb, ls1046ardb, ls1046afrwy,  
ls1088ardb_pb, ls2088ardb, ls2160ardb_rev2, lx2162aqds, etc


## FlexBuild Usage
------------------

```
$ cd flexbuild
$ source setup.env
$ bld -h

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
 bld -i mkfw -m ls1046ardb        # generate composite firmware (including atf, u-boot, optee_os, kernel, dtb, initramfs, etc) for ls1046ardb
 bld -i mkallfw -p IMX|LS         # generate composite firmware for all iMX or LS machines
 bld -i mkrfs                     # generate Ubuntu-based main arm64 userland, equivalent to "bld -i mkrfs -r ubuntu:main -a arm64" by default
 bld -i mkrfs -r ubuntu:desktop   # generate Ubuntu-based desktop arm64 userland
 bld -i mkrfs -r ubuntu:lite      # generate Ubuntu-based lite arm64 userland
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
 bld docker                       # create or attach Ubuntu docker container to build in docker
 bld list                         # list enabled machines and supported various components
```

## More info
------------
Please refer to [flexbuild_usage](docs/flexbuild_usage.md), [build_and_deploy_distro](docs/build_and_deploy_distro.md), [nxp_linux_sdk](docs/nxp_linux_sdk.md) for detailed information.
