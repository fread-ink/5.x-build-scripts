#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

set -eu

FAILED=0
DEST="root"

if [ "$#" -gt "0" ]; then
  DEST=$1
fi

echo "Completing userland root fs setup"
set +e
./chroot.sh $DEST /root/step2.sh
if [ "$?" -ne "0" ]; then
  echo "Error during setup. Aborting" > /dev/stderr
  FAILED=$?
fi

# Not sure why this is needed
# but some mounts appear to still be in use if we don't wait
sleep 3

set -e
./unmount.sh $DEST

if [ "$FAILED" -ne "0" ]; then
    exit 1
fi

rm ${DEST}/root/step2.sh

echo "Success!"

echo "You can now run:"
echo "  sudo ./chroot ${DEST}"
echo "and then to unmount anything inside the chroot directory:"
echo "  sudo ./unmount ${DEST}"
