#!/bin/bash
# Preparing a bootable, test SD card for EMEV
TEST=`pwd`
UBOOT=..

SDCARD=$1
if [ ! -b "$SDCARD" ]
then
    echo "'${SDCARD}' is not a block device!"
    exit -1
fi

echo "making SD-boot loaders ..."
cd $UBOOT
make distclean
make emev_sdtest_config
make
if [[ $? -ne 0 ]]
then
    echo "compilation failed"
    exit -1
fi
cp ./sdboot.bin $TEST/sdboot.bin
cp ./uboot-sd.bin $TEST/uboot-sd.bin

echo "You're about to erase all data on '${SDCARD}/' !"
read -p "If you're sure about that hit <ENTER>, or abort with <CTRL>-C" 

echo "partitioning SD card"
cd $TEST
sudo ./part_sd.sh $1
if [[ $? -ne 0 ]]
then
    echo "partitioning failed"
    exit -1
fi
echo "creating SD card content"
sudo ./create_sd.sh $1
if [[ $? -ne 0 ]]
then
    echo "creating SD failed"
    exit -1
fi
