#!/bin/bash

set +x -e
############################################
# Script to create a bootable sd card for
# the Renesas EMEV tablet
#
# Assuming these partitions exist:
# (Use part_sd.sh to create them)
#
# p1 500MB	: 	boot files
# p2 256KB	:	uboot environment
# p3 400MB	:	android-fs
# p4		:	EXTENDED
# p5 750MB	:	data-fs / cache
# p6 the rest	:	nand-fs
PBOOT="1"
PENV="2"
PANDROID="3"
PDATA="5"
PNAND="6"

SDCARD=$1

UBOOTDIR="."
AOSPDIR="."
KERNELDIR="."

UIMAGE="${KERNELDIR}/uImage4"
UIMAGENAME="uImage"
SDBOOT="${UBOOTDIR}/sdboot.bin"
SDBOOTNAME="sdboot.bin"
PATCHED_UBOOT="${UBOOTDIR}/uboot-sd.bin"
UBOOTSDNAME="uboot-sd.bin"
ANDROIDFS="${AOSPDIR}/android-fs4.tar.gz"
VOLDSTAB="vold.fstab"

echo "(1) Checking file availabilities ..."
ls -oh $SDBOOT
ls -oh $PATCHED_UBOOT
ls -oh $VOLDSTAB
ls -oh $UIMAGE
ls -oh $ANDROIDFS

mkdir -p _tmp_/pboot
mkdir -p _tmp_/pandroid
mkdir -p ./_tmp_/pdata/
mount -t vfat  ${SDCARD}${PBOOT} ./_tmp_/pboot/
mount -t ext3   ${SDCARD}${PANDROID} ./_tmp_/pandroid/
mount -t ext3   ${SDCARD}${PDATA} ./_tmp_/pdata/

echo "(2) Copying boot files"
rm -rf ./_tmp_/pboot/*
cp -vf $SDBOOT ./_tmp_/pboot/$SDBOOTNAME
cp -vf $UIMAGE ./_tmp_/pboot/$UIMAGENAME
cp -vf $PATCHED_UBOOT  ./_tmp_/pboot/$UBOOTSDNAME

echo "(3) Extracting Android fs"
rm -rf ./_tmp_/pandroid/*
tar zxf $ANDROIDFS -C ./_tmp_/pandroid/
# Patching vold file
cp -vpf ./$VOLDSTAB ./_tmp_/pandroid/system/etc/
# Patching init.rc for data partition
sed 's/mmcblk0p6/mmcblk1p5/' ./_tmp_/pandroid/init.rc > ./_tmp_/pandroid/init.rc.fix
cp -vpf ./_tmp_/pandroid/init.rc.fix ./_tmp_/pandroid/init.rc 

echo "(3) Cleaning up /data partition"
rm -rf ./_tmp_/pdata/*

echo "(4) Cleaning up env"
set +e
dd if=/dev/zero of=${SDCARD}${PENV} >/dev/null 2>&1
set -e

echo "(5) Sync ..."
sync

sleep 1
umount -f ./_tmp_/pboot/
umount -f ./_tmp_/pandroid/
umount -f ./_tmp_/pdata/
rm -rf _tmp_

echo "DONE."
