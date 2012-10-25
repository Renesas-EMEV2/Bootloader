#!/bin/bash

#version: 20110624, FF=2.1.06
#iNand partion
#p1: u-boot-emmc		[5M]
#p2: kernel				[10M]
#p3: cramfs				[50M]
#p4: extented partion	[]
#p5: android fs			[250M]
#p6: android data/cache	[750M]
#p7: FAT32

DEV_FRAMEBUFFER=/dev/fb
DEV_SD=/dev/mmcblk1p1
DEV_MMC=/dev/mmcblk0
SD_MOUNTPOINT=/tmp/sd
ANDROIDFS_MOUNTPOINT=/tmp/android
USER_MOUNTPOINT=/tmp/dcache
DATA_DIR=$USER_MOUNTPOINT/data
CACHE_DIR=$USER_MOUNTPOINT/cache
CRAMFS_MOUNTPOINT=/tmp/cramfs
NAND_MOUNTPOINT=/tmp/nand
FF_LOGFILE="$SD_MOUNTPOINT"/fflog
# For dd command
BYTES=2400
BLOCKS=480

msg_print()
{
	echo $1
	echo $1 >> $FF_LOGFILE
}

error()
{
    msg_print ""
    msg_print "--------------------------"
    msg_print "- INSTALL FAILED"
    msg_print "- check 'fflog' in SD home"
    msg_print "--------------------------"
    msg_print ""
    sync;sync;sync
    cd /
    umount $CRAMFS_MOUNTPOINT
    # umount $SD_MOUNTPOINT # do it in rcS
    echo "[cff" > $FF_LOGFILE
    echo "[D100" > $FF_LOGFILE
    echo "FAIL" > $FF_LOGFILE
    sleep 100000
    dd if=/dev/urandom of=$DEV_FRAMEBUFFER bs=$BYTES count=$BLOCKS
    exit 1
}

/tmp/ff4 -T -F $FF_LOGFILE &
sleep 3
# mkdir -p $SD_MOUNTPOINT # do it in rcS
# mount $DEV_SD $SD_MOUNTPOINT # do it in rcS
msg_print ""
msg_print "- INSTALL eMMC BOOT"
cd /
msg_print ""
msg_print "- CHECK u-boot-emmc"
if [ -f $SD_MOUNTPOINT/uboot4.bin ] ; then
    msg_print "found : $SD_MOUNTPOINT/uboot4.bin"
else
    msg_print "boot file not found"
    error
fi

msg_print ""
msg_print "- CHECK uImage"
if [ -f $SD_MOUNTPOINT/uImage4 ] ; then
    msg_print "found : $SD_MOUNTPOINT/uImage4"
else
    msg_print "kernel file not found"
    error
fi

msg_print ""
msg_print "- CHECK cramfs"
if [ -f $SD_MOUNTPOINT/cramfs4.tar.gz ] ; then
    msg_print "found : $SD_MOUNTPOINT/cramfs4.tar.gz"
else
    msg_print "cramfs.tar4.gz file not found"
    error
fi

msg_print ""
msg_print "- CHECK android-fs"
FS_FILE=`ls $SD_MOUNTPOINT/android-fs4.tar.gz`
if [ -f $SD_MOUNTPOINT/android-fs4.tar.gz ] ; then
    msg_print "found : $FS_FILE"
else
    msg_print "android-fs file not found"
    error
fi

cd $SD_MOUNTPOINT
msg_print ""
msg_print "- MAKE eMMC partitions"
fdisk "$DEV_MMC" <<EOF || error
d
1
d
2
d
3
d
4
d
n
p
1

+5M
n
p
2

+10M
n
p
3

+50M
n
e


n

+250M
n

+750M
n


t
7
c
w
EOF

cd /
if [ -b "$DEV_MMC"p1 ] ; then
    msg_print "found : "$DEV_MMC"p1"
else
    msg_print ""$DEV_MMC"p1 not found"
    error
fi
if [ -b "$DEV_MMC"p2 ] ; then
    msg_print "found : "$DEV_MMC"p2"
else
    msg_print ""$DEV_MMC"p2 not found"
    error
fi
if [ -b "$DEV_MMC"p3 ] ; then
    msg_print "found : "$DEV_MMC"p3"
else
    msg_print ""$DEV_MMC"p3 not found"
    error
fi
if [ -b "$DEV_MMC"p5 ] ; then
    msg_print "found : "$DEV_MMC"p5"
else
    msg_print ""$DEV_MMC"p5 not found"
    error
fi
if [ -b "$DEV_MMC"p6 ] ; then
    msg_print "found : "$DEV_MMC"p6"
else
    msg_print ""$DEV_MMC"p6 not found"
    error
fi
if [ -b "$DEV_MMC"p7 ] ; then
    msg_print "found : "$DEV_MMC"p7"
else
    msg_print ""$DEV_MMC"p7 not found"
    error
fi

msg_print ""
msg_print "- Create fat32 filesystem"
$SD_MOUNTPOINT/busybox mkfs.vfat "$DEV_MMC"p7 || error

msg_print ""
msg_print "- WRITE u-boot-emmc"
dd if=/dev/zero of="$DEV_MMC"p1 bs=1048576 count=5
dd if=$SD_MOUNTPOINT/uboot4.bin of="$DEV_MMC"p1 || error

msg_print ""
msg_print "- WRITE uImage"
dd if=$SD_MOUNTPOINT/uImage4 of="$DEV_MMC"p2 || error

msg_print ""
msg_print "- WRITE cramfs"
mkfs.ext3 "$DEV_MMC"p3 || error
mkdir -p $CRAMFS_MOUNTPOINT
mount -t ext3 "$DEV_MMC"p3 $CRAMFS_MOUNTPOINT
tar zxvf $SD_MOUNTPOINT/cramfs4.tar.gz -C $CRAMFS_MOUNTPOINT
mv $CRAMFS_MOUNTPOINT/cramfs/* $CRAMFS_MOUNTPOINT/
rm -r $CRAMFS_MOUNTPOINT/cramfs
sync;sync;sync
cd /

msg_print ""
msg_print "- WRITE android-fs"
mkfs.ext3 "$DEV_MMC"p5 || error
mkdir -p $ANDROIDFS_MOUNTPOINT
mount -t ext3 "$DEV_MMC"p5 $ANDROIDFS_MOUNTPOINT
tar zxvf $FS_FILE -C $ANDROIDFS_MOUNTPOINT
sync;sync;sync

msg_print ""
msg_print "- CREATE /data"
mkfs.ext3 "$DEV_MMC"p6 || error
mkdir -p $USER_MOUNTPOINT
mount -t ext3 "$DEV_MMC"p6 $USER_MOUNTPOINT
sync;sync;sync

if [ -d "$SD_MOUNTPOINT"/factory ] ; then
    msg_print "- copy factory data"
    mkdir -p $NAND_MOUNTPOINT
    mount -t vfat "$DEV_MMC"p7 $NAND_MOUNTPOINT
    cp -r $SD_MOUNTPOINT/factory/* $NAND_MOUNTPOINT
    sync;sync;sync
fi

if [ -f "$SD_MOUNTPOINT"/custom/custom.sh ] ; then
    msg_print "- execute custom.sh"
   "$SD_MOUNTPOINT"/custom/custom.sh $SD_MOUNTPOINT $ANDROIDFS_MOUNTPOINT $NAND_MOUNTPOINT
fi

cd /
umount $NAND_MOUNTPOINT
umount $USER_MOUNTPOINT
umount $CRAMFS_MOUNTPOINT
umount $ANDROIDFS_MOUNTPOINT
# umount $SD_MOUNTPOINT # do it in rcS

msg_print ""
msg_print "---------------------"
msg_print "- INSTALL COMPLETE!"
msg_print "---------------------"
msg_print ""

echo "[D1" > $FF_LOGFILE
echo "INSTALL COMPLETE" > $FF_LOGFILE
sleep 100000

dd if=/dev/zero of=$DEV_FRAMEBUFFER bs=$BYTES count=$BLOCKS

exit 0
