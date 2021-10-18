## How to add new application package/component in Flexbuild
- To add .deb package which can be installed directly by apt command for target Ubuntu/Debian userland
  just add new package name in extra_xx_packages_list in configs/ubuntu/extra_packages_list, then run
```
  $ bld -i clean-rfs -r <distro_type>:<distro_scale>
  $ bld -i mkrfs -r <distro_type>:<distro_scale>
```
  or directly install it in chroot environment on host machine as below:
```
  $ sudo chroot build/rfs/rootfs_<sdk_version>_ubuntu_main_arm64 apt install <package_name>
```


- To add custom package for building from source instead of binary package for target Ubuntu/Debian/CentOS/Yocto/Buildroot based userland
1. Assume adding a package called 'hello_world', edit configs/sdk.yml to configure the corresponding repo url/branch/tag if needed.
   (user can locally create the new component Git repository in components/apps/\<subsystem\>/\<component\> directory in case
    there is no available git repository)

2. Create a makefile src/apps/\<subsystem\>/hello_world.mk to add build object support for this component, e.g.
```
   $ vi src/apps/generic/hello_world.mk
     hello_world:
            @$(call fetch-git-tree,hello_world,apps/generic) && \
             cd $(GENDIR)/hello_world && \
             make && make install && \
             $(call fbprint_d,"hello_world")
```

3. Run command below to build new component against the specified target rootfs
```
     $  bld -c <component> -r <distro_type:distro_scale>
   e.g. bld -c hello_world -r ubuntu:main
     or bld -c hello_world -r ubuntu:desktop
```

4. Run command below to merger new component package into the target rootfs
```
     $  bld -i merge-component -r <distro_type:distro_scale>
   e.g. bld -i merge-component -r ubuntu:main
```

5. Run command below to pack the target rootfs
```
     $  bld -i packrfs -r <distro_type:distro_scale>
   e.g. bld -i packrfs -r ubuntu:main
```




## How to add a custom machine/board in Flexbuild
1. Run the commands below to fetch the source git repositories of SDK various components for the first time
```
   $ cd flexbuild
   $ source setup.env
   $ bld -i repo-fetch
```

2. Add BSP patch for custom machine if needed
   - add atf patch for custom machine in components/bsp/atf
   - add u-boot patch for custom machine in components/bsp/uboot
   - add linux patch for custom machine in components/linux/linux
   - add optee patch for custom machine in components/apps/security/optee_os

3. Add configs for custom machine in flexbuild
   - add "MACHINE_NAME: y" under CONFIG_MACHINE in configs/sdk.yml
   - Add custom machine node in configs/linux/linux_arm64_IMX.its (or linux_arm64_LS.its)
   - Add manifest config for the custom machine
```
      $ mkdir configs/board/<machine>
      then copy an existing manifest of similiar board to this new direco for reference and
      set proper configuration in configs/board/<machine>/manifest for this custom machine.
```

4. Build composite image for the custom machine
```
   $ bld -c atf -m <machine>
   $ bld -c uboot -m <machine>
   $ bld -c linux -p IMX (or -p LS)
   $ bld -i mkitb -r yocto:tiny -p IMX (or -p LS)
   $ bld -i mkfw -m <machine>
```

5. program composite image into SD card
```
   $ sudo dd if=firmware_<machine>_sdboot.img of=/dev/mmcblk0 bs=1k seek=<offset>
```

6. plug SD card onto target board and boot the TinyLinux under U-Boot
   - for iMX:
```
   => mmc read $loadaddr 0x3000 0x1f000 && bootm $loadaddr#<board_name>
```
   - for LS:
```
   => mmc read $loadaddr 0x8000 0x1f000 && bootm $loadaddr#<board_name>
```
