#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

echo -n "Deleting old build files... "

rm -rf busybox
rm -rf busybox-*
rm -f initramfs.cpio

echo "done"
