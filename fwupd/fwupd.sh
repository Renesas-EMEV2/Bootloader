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
cp ./sdboot.bin ./fwupd/files/sdboot.bin
cp ./uboot-sd.bin ./fwupd/files/uboot-sd.bin
echo "making EMMC-boot loader ..."
make distclean
make emev_emmc_config
make
if [[ $? -ne 0 ]]
then
    echo "compilation failed"
    exit -1
fi
cp ./u-boot-emmc.bin ./fwupd/files/uboot4.bin

echo "calculating MD5 checksums ..."
MD5=`md5sum ./fwupd/files/android-fs4.tar.gz | awk '{print $1}'`
echo "androidfs="$MD5 > ./fwupd/files/update.conf
MD5=`md5sum ./fwupd/files/uboot4.bin | awk '{print $1}'`
echo "uboot="$MD5 >> ./fwupd/files/update.conf
MD5=`md5sum ./fwupd/files/uImage4 | awk '{print $1}'`
echo "uimage="$MD5 >> ./fwupd/files/update.conf

if [[ $? -ne 0 ]]
then
    echo "MD5 checksum failed"
    exit -1
fi

echo "moving files to destination ..."
cp -r ./fwupd/files/* $DEST
sync
echo "DONE"

