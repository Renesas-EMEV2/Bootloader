#!/bin/sh
# Preparing bootloader files SD for EMEV firmware update


UBOOT=..
DEST=$1

if [ $# -eq 0 ] ; then
	echo "Usage: fwupd.sh <destination>"
	exit 1
fi

if [ ! -d ${1} ] ; then
	echo "Invalid destination dir"
	exit 1
fi

echo "making SD-boot loaders ... "
cd $UBOOT
make distclean
if [[ $? -ne 0 ]]
then
    echo "SD-boot make clean failed"
    exit -1
fi
make emev_sd_line_config
if [[ $? -ne 0 ]]
then
    echo "SD-boot make config failed"
    exit -1
fi
make
if [[ $? -ne 0 ]]
then
    echo "SD-boot make failed"
    exit -1
fi
cp ./sdboot.bin ./fwupd/files/sdboot.bin
cp ./uboot-sd.bin ./fwupd/files/uboot-sd.bin

echo "making EMMC-boot loader ..."
make distclean
if [[ $? -ne 0 ]]
then
    echo "EMMC-boot make clean failed"
    exit -1
fi
make emev_emmc_config
if [[ $? -ne 0 ]]
then
    echo "EMMC-boot make config failed"
    exit -1
fi
make
if [[ $? -ne 0 ]]
then
    echo "EMMC-boot make failed"
    exit -1
fi
cp ./u-boot-emmc.bin ./fwupd/files/uboot4.bin

echo "calculating MD5 checksums ..."
./fwupd/md5.sh ./fwupd/files
if [[ $? -ne 0 ]]
then
    echo "MD5 checksums failed"
    exit -1
fi

echo "moving files to destination ..."
cp -r ./fwupd/files/* $DEST
if [[ $? -ne 0 ]]
then
    echo "file copy failed"
    exit -1
fi
sync
echo "DONE"

