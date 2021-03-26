#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

DEST="root"

if [ "$#" -gt "0" ]; then
  DEST=$1
fi

CMD=""
if [ "$#" -gt "1" ]; then
  CMD=$2
fi

set -eu

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

if [ -z "$CMD" ]; then
  echo "Changing root to $DEST"
  chroot . /usr/bin/env -i su -l
else
  chroot . /usr/bin/env -i $CMD    
fi




