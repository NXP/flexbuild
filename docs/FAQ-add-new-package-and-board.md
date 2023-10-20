## How to add new application package/component in Flexbuild
- To add binary debian package which can be installed directly by apt command for arm64 target userland
  just add new package name in configs/debian/debian-<distro_variant>-arm64.yaml, then run
```
  $ sudo rm -rf components/bookworm_<distro_variant>_arm64
  $ bld clean-rfs -r <distro_type>:<distro_variant>
  $ bld rfs -r <distro_type>:<distro_scale>
e.g.
  $ bld clean-rfs -r debian:desktop (or '-r debian:server')
  $ bld rfs -r debian:desktop
```
  or directly install it via chroot on the host machine as below:
```
  $ sudo chroot build/rfs/rootfs_<sdk_version>_debian_<distro_variant>_arm64 apt install <package_name>
```


- To add custom component/package to compile it from source code against arm64 debian rootfs
1. Assume adding a new package called 'hello_world', edit configs/sdk.yml to configure the corresponding repo url/branch/tag if needed.
   (user can locally create the new component Git repository in components/apps/\<subsystem\>/\<component\> directory in case
    there is no available remote git repository)

2. Create a makefile file src/apps/\<subsystem\>/hello_world.mk to add the build object for this component, e.g.
```
   $ vi src/apps/utils/hello_world.mk
     hello_world:
            @$(call fetch-git-tree,hello_world,apps/generic) && \
             cd $(GENDIR)/hello_world && \
             $(MAKE) -j$(JOBS) && \
	     $(MAKE) install && \
             $(call fbprint_d,"hello_world")
```

3. Build the new component against the specified target rootfs
```
     $  bld <component> [ -r <distro_type:distro_scale> ]
   e.g. bld hello_world (or -r debian:desktop or debian:server)
```

4. Merger the new component into the target rootfs
```
     $  bld merge-apps [ -r <distro_type:distro_scale> ]
   e.g. bld merge-apps (or -r debian:desktop or debian:server)
```

5. Pack the target rootfs
```
     $  bld packrfs [ -r <distro_type:distro_scale> ]
   e.g. bld packrfs  (or -r debian:desktop or debian:server)
```




## How to add a custom machine/board in Flexbuild
1. Run the commands below to fetch the source git repositories of SDK various components for the first time
```
   $ git clone https://github.com/flexbuild/flexbuild
   $ cd flexbuild
   $ source setup.env
   $ bld repo-fetch
```

2. Optionally, add BSP related patches for the custom machine if needed
   - add atf patch for custom machine in components/bsp/atf
   - add u-boot patch for custom machine in components/bsp/uboot
   - add linux patch for custom machine in components/linux/linux
   - add optee patch for custom machine in components/apps/security/optee_os

3. Add configs for custom machine in flexbuild
   - Add a config file in configs/board/\<machine\>.conf for the new custom machine (copy an existing board with custom modification)
   - Optionally, add custom machine node in configs/linux/linux_arm64_IMX.its (or linux_arm64_LS.its)

4. Build the composite firmware image for the custom machine
```
   $ bld clean-bsp (optionally, to clean the obsolete bsp images)
   $ bld atf -m <machine>
   $ bld uboot -m <machine>
   $ bld linux  (or add option '-p LS' for Layerscape platforms)
   $ bld fw -m <machine>
```

5. Optionally, to build application components against Debian userland for the custom machine
```
    $ bld apps [ -r debian:server ]
    $ bld merge-apps [ -r debian:server ]
    $ bld packrfs [ -r debian:server ]
```

6. Deploy distro image to SD card
   - To only install the composite firmware image into SD card
```
   $ sudo dd if=firmware_<machine>_sdboot.img of=/dev/mmcblk0 bs=1k seek=<offset>
 e.g sudo dd if=firmware_imx8mpevk_sdboot_lpddr4.img of=/dev/mmcblk0 bs=1k seek=32 
     sudo dd if=firmware_lx2160ardb_sdboot.img of=/dev/mmcblk0 bs=1k seek=4
```
   - To install all the distro images onto SD/eMMC card or USB/SATA storage device
```
   $ flex-installer -i pf -d /dev/sdx
   $ flex-installer -b <boot> -r <rootfs> -d <device> -m <machine> [ -f <firmware> ]
     (the '-f <firmware>' option is only for SD boot, no need it for USB/SATA storage device)
```

7. Plug SD card onto the target board and power on, it will automatically boot to Debian system
   (if the automated distro boot in u-boot doesn't support your target board, manually boot it by setting the appropriate u-boot env)

8. Optionally, for booting to the TinyLinux environment under U-Boot
   - for iMX:
```
   => mmc read $load_addr 0x4000 0x1f000 && bootm $load_addr#<board_name>
 e.g. mmc read 0xa0000000 0x4000 0x1f000 && bootm a0000000#imx8mpevk
```
   - for LS:
```
   => mmc read $load_addr 0x8000 0x1f000 && bootm $load_addr#<board_name>
```
