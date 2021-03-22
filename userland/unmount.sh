#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

usage() {
  echo "Usage: $0 <chroot_dir>"
}

if [ "$#" -lt "1" ]; then
  usage
  exit 1
fi

set -eu

CHROOT_DIR=$(realpath $1)
echo $CHROOT_DIR
if [ ! -f "${CHROOT_DIR}/etc/apk/world" ]; then
    
  echo "This does not appear to be a fread.ink root filesystem" > /dev/stderr
  exit 1
fi

echo "Unmounting all mounts under $CHROOT_DIR"
COUNT=0
cat /proc/mounts | cut -d' ' -f2 | grep "^$CHROOT_DIR" | sort -r | while read path; do
  umount -fn "$path" || exit 1
  COUNT=$(($COUNT+1))  
done
echo "Unmounted $COUNT dirs"
