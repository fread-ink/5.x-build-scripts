#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

DEST="root"

if [ "$#" -gt "0" ]; then
  DEST=$1
fi

set -eu

CHROOT_DIR=$(realpath $DEST)
echo $CHROOT_DIR
if [ ! -f "${CHROOT_DIR}/etc/apk/world" ]; then
    
  echo "This does not appear to be a fread.ink root filesystem" > /dev/stderr
  exit 1
fi

echo "Unmounting all mounts under $CHROOT_DIR"
set +e

cat /proc/mounts | cut -d' ' -f2 | grep "^$CHROOT_DIR" | sort -r | while read path; do
#  echo "Unmounting $path"  
  umount -fn "$path"
done

