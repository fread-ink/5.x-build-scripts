#!/bin/sh

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  exit 1
fi

if [ ! -f "/root/step2.sh" ]; then
    echo "This script should only be run from within the chroot evironment." > /dev/stderr
    exit 1
fi

set -eu

apk update
apk add dropbear dropbear-ssh nano dnsmasq

# Make dnsmasq auto-start on boot
rc-update add dnsmasq
