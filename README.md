Work In Progress

Scripts to build the new version of fread.ink that's based on a 5.x kernel and the Alpine distro.

# initramfs

The **init**ial **ram** **f**ile**s**ystem. This is a tiny busybox-based userland filesystem that will be embedded in the kernel. It is used to mount what needs mounting before booting into the real userland filesystem.

Since it is embedded in the kernel you should build it before building the kernel.

## Pre-requisites

```
sudo apt install cpio
```

## Build

Download and configure busybox:

```
cd initramfs/
./download.sh
```

Change configuration (optional):

```
./menuconfig.sh
```

Build and install into staging directory:

```
./build.sh
./install.sh
```

Create `.cpio` file for inclusion in kernel:

```
sudo ./cpio.sh
```

# Userland

## Pre-requisites

```
sudo apt install qemu-system-arm qemu-user-static binfmt-support
update-binfmts --enable
```

## Build

```
cd userland/

# Create a userland in `./root`
sudo ./create.sh 

# Second step of create script
sudo ./create_step2.sh
```

Optionally you can `chroot` into the userland and make your own modifications before proceeding.

```
# chroot into it
sudo ./chroot.sh root

# ctrl-d to exit

# unmount all bind mounts for the userland
sudo ./unmount.sh root
```

Follow along with the next section to build the kernel and install the kernel modules, then the section after that will show you how to bundle up the userland for use with fread.ink.

# Kernel

## Pre-requisites

```
sudo ./kernel/install_dependecies.sh
```

## Build

Download kernel source:

```
cd kernel/
git clone --depth=1 https://github.com/fread-ink/linux-5.x-wip
```

Configure kernel:

```
cp CONFIG linux/.config
```

Optionally change manually reconfigure:

```
./menuconfig.sh
```

Build:

```
./build.sh
```

Install modules to userland:

```
./install.sh
```

# Userland continued

Bundle filesystem into `.ext4` file:

TODO