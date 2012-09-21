#!/bin/sh
export UPDATE_DIR=/tmp/sd/
export UBOOT_PARTITION=/dev/mmcblk0p1
export KERNEL_PARTITION=/dev/mmcblk0p2
export ROOTFS_PARTITION=/dev/mmcblk0p5
export ROOTFS_PATH=/tmp/rootfs/
export FS_PACKAGE=$UPDATE_DIR/android-fs4.tar.gz
export KERNEL_IMG=$UPDATE_DIR/uImage4
export UBOOT_IMG=$UPDATE_DIR/uboot4.bin
export SUCCESS_IMG=$UPDATE_DIR/success.bmp
export UPDATE_IMG=$UPDATE_DIR/update.bmp

cat $UPDATE_IMG > /dev/fb
#update uboot
if [ -f $UBOOT_IMG ]; then
	dd if=$UBOOT_IMG of=$UBOOT_PARTITION
fi

#Update kernel image
if [ -f $KERNEL_IMG ]; then
	dd if=$KERNEL_IMG of=$KERNEL_PARTITION
fi

#update rootfs
if [ -f $FS_PACKAGE ]; then
mkdir -p $ROOTFS_PATH
mount $ROOTFS_PARTITION $ROOTFS_PATH
rm -rf $ROOTFS_PATH/*
tar xf $FS_PACKAGE -C $ROOTFS_PATH
umount $ROOTFS_PATH
fi

cat $SUCCESS_IMG > /dev/fb

