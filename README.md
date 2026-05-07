## FlexBuild Overview
---------------------
FlexBuild is an easy-to-use, lightweight build tool for compiling and deploying Debian-based 
Linux systems on NXP platforms.

It provides a streamlined workflow to build complete Debian systems, including the Linux kernel, 
BSP components, and various userspace applications (graphics, multimedia, networking, security, 
AI/ML, etc.). FlexBuild simplifies the entire build process with efficient CI/CD integration.

With the included flex-installer utility, you can easily deploy the built Debian system to 
target storage devices (SD/eMMC card or USB/SATA disk) on NXP boards or host machines.


## Host system requirement
- Ubuntu LTS host (22.04, 24.04) with docker installed.


## Supported platforms
----------------------
- __iMX platform__:  
imx8mmevk, imx8mpevk, imx8mpfrdm, imx8qmmek, imx91evk, imx91frdm, imx91sfrdm, imx93evk,
imx93frdm, imx95-15x15-frdm, imx95-15x15-evk, imx95-19x19-frdm-pro, imx95-19x19-evk

- __Layerscape platform__:  
ls1028ardb, ls1043ardb, ls1046ardb, lx2160ardb


## Flexbuild Usage
------------------

Build all images in 3 steps:
```
$ cd flexbuild
$ make docker                                    # Step 1: Create or attach to Docker build container
$ make menuconfig (or make <machine>_defconfig)  # Step 2: Select target machine and applications (if needed)
$ make all                                       # Step 3: Build all required images (bootloader + kernel  + rootfs)
```

Most used examples with separate command:
```
$ make bsp             # Generate BSP composite firmware (primarily for Layerscape platforms)
$ make flash.bin       # Generate flash.bin composite firmware (for iMX platforms)
$ make atf             # Compile ARM Trusted Firmware (ATF) image for SD boot
$ make boot            # Generate boot partition tarball (kernel, DTB, distro boot script)
$ make linux           # Compile Linux kernel
$ make uboot           # Compile U-Boot bootloader

$ make apps            # Compile NXP-specific components with runtime dependencies
$ make merge-apps      # Merge compiled NXP components into rootfs
$ make rfs             # Generate Debian-based root filesystem
$ make packrfs         # Pack and compress rootfs as rootfs_<distro_version>_debian_<machine>_arm64.tar.zst

$ make clean-bsp       # Clean BSP components (U-Boot/ATF/firmware)
$ make clean-linux     # Clean Linux kernel build artifacts
$ make clean-apps      # Clean NXP application components
$ make clean-rfs       # Clean Debian root filesystem

$ make docker          # Create or attach to Docker build container
$ make list            # List all supported machines
$ make help            # Display detailed help information
```

## More info
------------
Please refer to [NXP Debian Linux SDK Distribution](https://www.nxp.com/nxpdebian) for more information.

The detailed user guide is available at [Debian Linux SDK User's Guide](https://www.nxp.com/docs/en/user-guide/UG10155.pdf).