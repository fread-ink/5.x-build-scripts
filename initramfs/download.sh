#!/bin/bash

set -eu

BUSYBOX_URI="https://busybox.net/downloads/busybox-1.32.1.tar.bz2"
BUSYBOX_FILENAME="${BUSYBOX_URI##*/}"
BUSYBOX_DIR="${BUSYBOX_FILENAME%.tar.*}"

if [ -f "$BUSYBOX_FILENAME" ]; then
  echo "Looks like $BUSYBOX_FILENAME already exists" > /dev/stderr
  exit 1
fi

echo -n "Downloading BusyBox... "
wget -T 10 --no-verbose --quiet "$BUSYBOX_URI"
echo "done"

if [ -d "$BUSYBOX_DIR" ]; then
  echo "Looks like the directory ${BUSYBOX_DIR/} already exists" > /dev/stderr
  exit 1
fi

echo -n "Extracting BusyBox... "
tar -xjf $BUSYBOX_FILENAME
echo "done"

echo -n "Creating symlink... "
ln -s $BUSYBOX_DIR busybox
echo "done"

echo -n "Configuring BusyBox... "
cp CONFIG $BUSYBOX_DIR/.config
echo "done"
