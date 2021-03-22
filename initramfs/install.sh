#!/bin/bash

cd busybox/
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- install
cd ..
