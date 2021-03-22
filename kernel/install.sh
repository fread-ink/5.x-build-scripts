#!/bin/bash

set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

if [ ! -d "built/lib" ]; then
  echo "No kernel modules to install" > /dev/stderr
  exit 1
fi

echo "Copying kernel modules to userland filesystem"
cp -a built/lib ../userland/root/
echo "done"

set +eu
