#!/bin/sh
# Calculating MD5 checksums, for EMEV firmware update

DEST=$1

MD5=`md5sum \$DEST/android-fs4.tar.gz | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    exit -1
fi
echo "androidfs="$MD5 > $DEST/update.conf
MD5=`md5sum \$DEST/uboot4.bin | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    exit -1
fi
echo "uboot="$MD5 >> $DEST/update.conf
MD5=`md5sum \$DEST/uImage4 | awk '{print $1}'`
if [[ $? -ne 0 ]]
then
    exit -1
fi
echo "uimage="$MD5 >> $DEST/update.conf

