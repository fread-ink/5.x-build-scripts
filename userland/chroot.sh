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

DEST=$1

echo "Bind-mounting /proc /sys and /dev"
echo "use ./unmount.sh to undo this later"

cd $DEST
mount -v -t proc none proc
mount -v --rbind /sys sys
mount --make-rprivate sys
mount -v --rbind /dev dev
mount --make-rprivate dev

# Some systems symlinks /dev/shm to /run/shm.
if [ -L /dev/shm ] && [ -d /run/shm ]; then
	mkdir -p run/shm
	mount -v --bind /run/shm run/shm
	mount --make-private run/shm
fi

echo "Changing root to $DEST"
chroot . /usr/bin/env -i su -l
