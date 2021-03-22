#!/bin/bash

cd busybox/
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j 8 
cd ..
