
#!/bin/sh

# created by juul

set -e

#objcopy -I ihex -O binary firmware/imx/sdma/sdma-imx50.bin.ihex firmware/imx/sdma/sdma-imx50.bin

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- imx50_kindle4nt_defconfig
