# Preparing bootloader files SD for EMEV firmware update
#!/bin/sh

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
make emev_sd_line_config
make
if [[ $? -ne 0 ]]
then
    echo "compilation failed"
    exit -1
fi
cp ./sdboot.bin $DEST/sdboot.bin
cp ./uboot-sd.bin $DEST/uboot-sd.bin

echo "making EMMC-boot loader ..."
make distclean
make emev_emmc_config
make
if [[ $? -ne 0 ]]
then
    echo "compilation failed"
    exit -1
fi
cp ./u-boot-emmc.bin $DEST/uboot4.bin

echo "calculating MD5 checksums ..."
MD5=`md5sum ./fwupd/files/android-fs4.tar.gz | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    echo "MD5 checksum failed"
    exit -1
fi
echo "androidfs="$MD5 > ./fwupd/files/update.conf
MD5=`md5sum $DEST/uboot4.bin | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    echo "MD5 checksum failed"
    exit -1
fi
echo "uboot="$MD5 >> ./fwupd/files/update.conf
MD5=`md5sum ./fwupd/files/uImage4 | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    echo "MD5 checksum failed"
    exit -1
fi
echo "uimage="$MD5 >> ./fwupd/files/update.conf

echo "moving files to destination ..."
cp -r ./fwupd/files/* $DEST
sync
echo "DONE"

