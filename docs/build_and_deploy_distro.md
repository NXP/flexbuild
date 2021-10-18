## Build and Deploy Various Distro
----------------------------------
FlexBuild supports generating various distro in different scale, including rich OS (Ubuntu-based, Debian-based, CentOS-based)
and embedded Linux distro (e.g. Yocto-based or Buildroot-based). Users can choose an appropriate distro according to demand as below:

```
Usage: bld -i mkrfs [ -r <distro_type>:<distro_scale> ] [ -a <arch> ]
$ bld -i mkrfs -r ubuntu:main          # generate ubuntu-based main userland for as per extra_main_packages_list for networking
$ bld -i mkrfs -r ubuntu:desktop       # generate Ubuntu-based desktop userland with main packages and gnome desktop for multimedia
$ bld -i mkrfs -r ubuntu:devel         # generate Ubuntu-based devel userland with more main and universe packages for development
$ bld -i mkrfs -r ubuntu:lite          # generate Ubuntu-based lite userland with base packages
$ bld -i mkrfs -r debian:main          # generate Debian-based main userland with main packages
$ bld -i mkrfs -r centos               # generate CentOS-based arm64 userland
$ bld -i mkrfs -r yocto:tiny           # generate Yocto-based tiny arm64 userland
$ bld -i mkrfs -r yocto:devel          # generate Yocto-based devel arm64 userland
$ bld -i mkrfs -r buildroot:tiny       # generate Buildroot-based tiny arm64 userland
$ bld -i mkrfs -r buildroot:devel      # generate Buildroot-based devel arm64 userland
```
To quickly install a new apt package to target Ubuntu-based arm64 userland on host machine, run the command as below
```
$ sudo chroot build/rfs/rootfs_<sdk_version>_ubuntu_main_arm64 apt install <package>
```



__Example: Build and deploy Ubuntu-based desktop distro for multimedia graphics scenario__
```
$ bld -i mkfw -m imx8mpevk      # generate composite firmware_imx8mpevk_sdboot_lpddr4.img
$ bld -i mkrfs                  # generate ubuntu-based desktop userland ('-r ubuntu:desktop' by default for IMX)
$ bld -i mkboot                 # genrate boot_IMX_arm64_lts_<version>.tgz  ('-p IMX' by default)
$ bld -c apps                   # build all apps components against ubuntu-based desktop userland
$ bld -i merge-component        # merge apps components into target ubuntu-based desktop userland
$ bld -i packrfs                # pack and compress target userland as .tgz
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_desktop_arm64.tgz -b boot_IMX_arm64_lts_<version>.tgz -f firmware_imx8mpevk_sdboot_lpddr4.img -d /dev/sdx
```



__Example: Build and deploy ubuntu-based main distro for networking scenario__
```
$ bld -i mkfw -m ls1046ardb             # generate composite firmware_ls1046ardb_sdboot.img
$ bld -i mkrfs -r ubuntu:main           # generate ubuntu-based main userland
$ bld -i mkboot -p LS                   # genrate boot_LS_arm64_lts_<version>.tgz
$ bld -c apps -r ubuntu:main -p LS      # build all apps components against ubuntu-based main userland
$ bld -i merge-component -r ubuntu:main # merge app components into target ubuntu-based main userland
$ bld -i packrfs -r ubuntu:main         # pack and compress target userland as .tgz
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_main_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/sdx
```
Note: The '-f <firmware> option is used for SD boot only'.




__Example: Build and deploy Ubuntu-based lite distro__
```
$ bld -i mkrfs -r ubuntu:lite
$ bld -i mkboot -p LS (or IMX)
$ bld -c apps -r ubuntu:lite
$ bld -i merge-component -r ubuntu:lite
$ bld -i packrfs -r ubuntu:lite
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_ubuntu_lite_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -d /dev/sdx
```
You can modify the default extra_lite_packages_list in configs/ubuntu/extra_packages_list to customize packages.




__Example: Build and deploy Yocto-based distro__
```
Usage: bld -i mkrfs -r yocto:<distro_scale> [ -a <arch> ]
The <distro_scale> can be tiny, devel,   <arch> can be arm32, arm64
$ bld -i mkrfs -r yocto:tiny (or '-r yocto:devel')
$ bld -i mkfw -m ls1028ardb  (or '-m imx8mpevk')
$ bld -i mkboot -p LS        (or '-p IMX')
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_yocto_tiny_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_ls1028ardb_sdboot.img -d /dev/sdx
```
You can customize extra packages to IMAGE_INSTALL_append in configs/yocto/local_arm64_<distro_scale>.conf, if you want to install
more packages(e.g. dpdk, etc) in yocto userland, you can choose devel instead of tiny. Additionally, you can add yocto
recipes for customizing package in src/misc/yocto/recipes-support directory, or you can add your own app component in
src/apps/\<subsystem\>/\<component\>.mk to integrate the new component into target Yocto-based rootfs.




__Example: Build and deploy Buildroot-based distro__
```
Usage: bld -i mkrfs -r buildroot:<distro_scale> -a <arch>
The <distro_scale> can be tiny, devel, imaevm,  <arch> can be arm32, arm64
$ bld -i mkrfs -r buildroot:devel:custom      # customize buildroot .config in interactive menu
$ bld -i mkrfs -r buildroot:devel             # generate buildroot userland
$ bld -i mkrfs -r buildroot:tiny              # generate arm64 rootfs as per arm64_tiny_defconfig
$ bld -i mkrfs -r buildroot:devel -a arm32    # generate arm32 rootfs as per arm32_devel_defconfig
$ bld -i mkrfs -r buildroot:imaevm            # generate arm64 rootfs as per arm64_imaevm_defconfig
$ bld -i mkfw -m ls1046ardb
$ bld -i mkfw -m imx8mpevk
$ bld -i mkboot -p LS
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_buildroot_tiny_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_ls1046ardb_sdboot.img -d /dev/mmcblk0
```
User can modify configs/buildroot/qoriq_<arch>_<distro_scale>_defconfig to customize various packages.




__Example: Build and deploy CentOS-based distro__
```
$ bld -i mkrfs -r centos
$ bld -i mkfw -m lx2162aqds
$ bld -i mkboot -p LS
$ bld -i merge-component -r centos
$ bld -i packrfs -r centos
$ cd build/images
$ flex-installer -r rootfs_<sdk_version>_centos_7.9.2009_arm64.tgz -b boot_LS_arm64_lts_<version>.tgz -f firmware_lx2162aqds_sdboot.img -d /dev/sdx
```
