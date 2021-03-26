#!/bin/bash

# Based on official Alpine chroot install script
# https://github.com/alpinelinux/alpine-chroot-install

if [ "$(id -u)" -ne 0 ]; then
  echo "You must be root to run this script." > /dev/stderr
  echo "This necessary because some of the files installed" > /dev/stderr
  echo "in the chroot dir must be owned by root." > /dev/stderr
  exit 1
fi

DEST="root"

if [ "$#" -gt "0" ]; then
  DEST=$1
fi

# This can be any of the versions in https://dl-cdn.alpinelinux.org/alpine/
# including "edge" or "latest-stable"
ALPINE_VERSION="v3.13"

# Link to the Alpine repo for the version to install
ALPINE_URL="https://dl-cdn.alpinelinux.org/alpine"
ALPINE_REPO="${ALPINE_URL}/${ALPINE_VERSION}/main/"

# No fread.ink repos yet
FREAD_REPOS=""

# Link to current apk-tools and the SHA256
APK_TOOLS_URI="https://github.com/alpinelinux/apk-tools/releases/download/v2.10.4/apk-tools-2.10.4-x86_64-linux.tar.gz"
APK_TOOLS_SHA256="efe948160317fe78058e207554d0d9195a3dfcc35f77df278d30448d7b3eb892"
APK_TOOLS_FILENAME="${APK_TOOLS_URI##*/}"

mkdir -p ${DEST}
mkdir -p bin

if [ ! -f "bin/apk" ]; then
  
    cd bin

    echo -n "Downloading apk-tools... "
    wget -T 10 --no-verbose "$APK_TOOLS_URI" --quiet

    if [ "$?" -ne "0" ]; then
        echo -e "\nDownloading apk-tools failed" > /dev/stderr
        exit 1
    fi
    echo "done"

    echo -n "Verifying apk-tools hash... "
    echo "$APK_TOOLS_SHA256 $APK_TOOLS_FILENAME" | sha256sum -c --status

    if [ "$?" -ne "0" ]; then
        echo -e "\nVerification of apk-tools failed" > /dev/stderr
        exit 1
    fi
    echo "done"

    set -eu

    echo -n "Extracting apk-tools... "
    tar -xvf $APK_TOOLS_FILENAME > /dev/null
    mv apk-tools-*/apk ./
    rm -rf apk-tools-*
    echo "done"
    cd ..
fi

set -eu

echo -n "Installing Alpine GPG keys... "
cd $DEST
mkdir -p etc/apk
cp -a ../alpine_keys etc/apk/keys
echo "done"

echo -n "Adding repository URLs..."
printf '%s\n' \
	"$ALPINE_URL/$ALPINE_VERSION/main" \
	"$ALPINE_URL/$ALPINE_VERSION/community" \
	$FREAD_REPOS \
	> etc/apk/repositories
echo "done"

echo -n "Copying system /etc/resolv.conf into Alpine root... "
cp /etc/resolv.conf etc/resolv.conf
echo "done"

echo -n "Creating /root dir... "
mkdir root
chmod 600 root
echo "done"

echo -n "Installing QEMU static binary... "
QEMU_STATIC_PATH=$(whereis -b qemu-arm-static)
QEMU_STATIC_PATH=${QEMU_STATIC_PATH##*:}
if [ -z $QEMU_STATIC_PATH ]; then
  echo -e "\nLooks like qemu-arm-static is not installed" > /dev/stderr
  echo "Take a look at the pre-requisites in the documentation" > /dev/stderr
  echo "and make sure you install qemu-user-static" > /dev/stderr
  exit 1
fi
mkdir -p usr/bin
cp $QEMU_STATIC_PATH usr/bin/
echo "done"

echo "Installing Alpine"
../bin/apk --root . --update-cache --initdb --arch armhf --repository $ALPINE_REPO add alpine-base

echo "Copying configuration and scripts"
cp -a conf/* ${DEST}/
cp scripts/step2.sh ${DEST}/root/
chmod 755 ${DEST}/root/step2.sh

echo "Succcess!"


