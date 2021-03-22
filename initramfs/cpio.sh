#!/bin/bash

set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

if [ -f initramfs.cpio ]; then
  echo "initramfs.cpio already exists" > /dev/stderr
  exit 1
fi

cd busybox/

echo -n "Installing init script... "
cp ../init _install/
chmod 755 _install/init
rm -f _install/linuxrc
echo "done"

echo -n "Creating directories... "
cd _install/
mkdir -p {proc,sys,etc,etc/init.d,lib,mnt,tmp,root}
echo "done"

echo -n "Creating /dev device nodes... "
rm -rf dev
../../makenodes.sh
echo "done"

echo "Writing initramfs.cpio"
find . -print0 | cpio --null -H newc -o > ../../initramfs.cpio
echo "done"

cd ../..

set +eu
