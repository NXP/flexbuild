## Build and Deploy Various Distro
----------------------------------
FlexBuild supports generating various distro in different scale, including rich OS (Debian-based) and embedded
Linux distro (Yocto-based, Buildroot-based). Users can choose an appropriate distro according to use case.

```
Usage: bld rfs [ -r <distro_type>:<distro_variant> ] [ -a <arch> ]
$ bld rfs -r debian:base          # generate Debian-based base userland with basic packages
$ bld rfs -r debian:desktop       # generate Debian-based desktop userland (with GPU/NPU/VPU/ISP HW acceleration) for HMI/Multimedia use case
$ bld rfs -r debian:server        # generate Debian-based server userland (w/o GUI desktop) for Industrial/IoT/Networking/Connectivity use case
$ bld rfs -r poky:tiny           # generate Yocto-based tiny arm64 userland
$ bld rfs -r poky:devel          # generate Yocto-based devel arm64 userland
$ bld rfs -r buildroot:tiny       # generate Buildroot-based tiny arm64 userland
$ bld rfs -r buildroot:devel      # generate Buildroot-based devel arm64 userland
```
To quickly install a new .deb package onto the target debian-based arm64 userland on host machine, run the command as below
```
$ sudo chroot build/rfs/rootfs_<sdk_version>_debian_desktop_arm64 apt install <package-name>
```



__Example: Build and deploy debian-based desktop distro for multimedia graphics scenario__
```
$ bld fw -m imx8mpevk      # generate composite firmware_imx8mpevk_sdboot_lpddr4.img
$ bld rfs                  # generate debian-based desktop userland ('-r debian:desktop' by default)
$ bld boot                 # genrate boot_IMX_arm64_lts_<version>.tar.zst  ('-p IMX' by default)
$ bld apps                   # build all apps components against debian-based desktop userland
$ bld merge-apps             # merge apps components into target debian-based desktop userland
$ bld packrfs                # pack and compress target userland as .tar.zst (optionally)

$ cd build/images
$ flex-installer -i pf -d /dev/sdx
$ flex-installer -f firmware_imx8mpevk_sdboot_lpddr4.img -b boot_IMX_arm64_lts_xx.tgz \
                 -r ../../build/rfs/rootfs_lsdkxx_debian_desktop_arm64 -d /dev/sdx -m imx8mpevk
```



__Example: Build and deploy debian-based server distro for industrial/iot/networking scenario__
```
$ bld fw -m lx2160ardb             # generate composite firmware_lx2160ardb_xxboot.img
$ bld rfs -r debian:server         # generate debian-based server userland
$ bld boot -p LS                   # genrate boot_LS_arm64_lts_<version>.tar.zst
$ bld apps -r debian:server -p LS    # build NXP-specific apps components against debian-based server userland
$ bld merge-apps -r debian:server    # merge apps components into target debian-based server userland
$ bld packrfs -r debian:server       # pack and compress target userland as .tgz

$ cd build/images
$ flex-installer -i pf -d /dev/sdx
$ flex-installer -f firmware_lx2160ardb_sdboot.img -b boot_LS_arm64_lts_xx.tgz \
                 -r ../../build/rfs/rootfs_lsdkxx_debian_server_arm64 -d /dev/sdx -m lx2160ardb
```
Note: The '-f <firmware>' option is used for SD boot only, no need it when deploying image on USB/SATA storage device.

User can modify the default package names in configs/debian/debian-xx-arm64.yaml to add/remove Debian deb packages.



__Example: Build and deploy Yocto-based distro__
```
Usage: bld rfs -r poky:<distro_scale> [ -a <arch> ]
The <distro_scale> can be tiny, devel,   <arch> can be arm32, arm64
$ bld rfs -r poky:tiny (or '-r poky:devel')
$ bld fw -m ls1046ardb  (or '-m imx8mpevk')
$ bld boot -p LS        (or '-p IMX')
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_poky_tiny_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
```
You can customize extra packages to IMAGE_INSTALL_append in configs/poky/local_arm64_<distro_scale>.conf in case you want to install
more packages(e.g. dpdk, etc) in poky userland, you can choose devel instead of tiny.
Additionally, you can add poky recipes for customizing package in src/misc/poky/recipes-support directory.
In another way, you can add your own app component in src/apps/\<subsystem\>/\<component\>.mk to integrate the new component into target Yocto-based rootfs.




__Example: Build and deploy Buildroot-based distro__
```
Usage: bld rfs -r buildroot:<distro_scale> -a <arch>
The <distro_scale> can be tiny, devel, imaevm,  <arch> can be arm32, arm64
$ bld rfs -r buildroot:devel:custom      # customize buildroot .config in interactive menu
$ bld rfs -r buildroot:devel             # generate buildroot userland
$ bld rfs -r buildroot:tiny              # generate arm64 rootfs as per arm64_tiny_defconfig
$ bld rfs -r buildroot:devel -a arm32    # generate arm32 rootfs as per arm32_devel_defconfig
$ bld rfs -r buildroot:imaevm            # generate arm64 rootfs as per arm64_imaevm_defconfig
$ bld fw -m ls1046ardb
$ bld fw -m imx8mpevk
$ bld boot -p LS
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_buildroot_tiny_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0
```
User can modify the config file configs/buildroot/<arch>_<distro_scale>_defconfig to customize various packages.
