#!/bin/bash

# Based on official Alpine chroot install script
# https://github.com/alpinelinux/alpine-chroot-install

# Usage:
#  sudo ./bundle.sh [rootfs_dir] [output.ext4] [free_space_in_MB]

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

set -eu

SOURCE="root" # input dir
if [ "$#" -gt "0" ]; then
  SOURCE=$1
fi

DEST="${SOURCE}.ext4" # output file
if [ "$#" -gt "1" ]; then
  DEST=$2
fi

EXTRA=25 # extra free space to include in MB
if [ "$#" -gt "2" ]; then
  EXTRA=$3
fi
EXTRA=$((EXTRA * 1024))

if [ ! -d "$SOURCE" ]; then
  echo "The directory $SOURCE does not exist" > /dev/stderr
  exit 1
fi

if [ -f "$DEST" ]; then
  echo "The file $DEST already exists" > /dev/stderr
  exit 1
fi

echo "Calculating required filesystem size"
KBYTES=$(du -s $SOURCE | cut -f 1)
KBYTES=$((KBYTES + EXTRA))

echo "Creating $KBYTES kB (~$((KBYTES/1024)) MB) empty file"
dd if=/dev/zero of=$DEST bs=1k count=$KBYTES

echo "Formatting empty file as ext4"
mkfs.ext4 -T small $DEST

echo "Disabling automatic fsck on mount" # because it doesn't yet work
tune2fs -c 0 -i 0 $DEST 

echo "Loop-mounting filesystem"
TMPDIR=$(mktemp -d -t fread_XXXXXXXX)
if [ -z "$TMPDIR" ]; then
  echo "Failed to create temporary directory" > /dev/stderr
  exit 1
fi
mount -o loop $DEST $TMPDIR # loop-mount the file

echo "Copying files to loop-mounted filesystem"
cp -a ${SOURCE}/* ${TMPDIR}/

echo "Cleaning up"
rm ${TMPDIR}/usr/bin/qemu-arm-static # delete the emulator binary
umount $TMPDIR
rm -rf $TMPDIR

echo "Done"
