#!/system/bin/sh
#
# This script shouldn't normally be used, unless internal NAND partitioning was corrupted
#
# To run this script you should 
#
# 1) connecy to the device with a serial console cable
# 2) modify "install.sh" adding an "exit 0" on first line, after "#!/bin/sh"
# 3) start the firmware update with SD card inserted and wait for console prompt
# 4) manually execute on console the following cmmands:
#     mkdir /tmp/fs
#     mount -t vfat -o codepage=932,iocharset=euc-jp,sync /dev/mmcblk1p1 /tmp/sd
#     /tmp/sd/part_emmc-sh
#
# ------------------------------
# EMMC partitioning scheme
#
# p1:   1M  u-boot-emmc
# p2:   8M  uImage
# p3:   2G  android /
# p4:  ---  extented partition
# p6:   1G  android data
# p7: ----  user data (VFAT)

DEV_EMMC=/dev/mmcblk0

busybox fdisk "$DEV_EMMC" <<EOF
d
1
d
2
d
3
d
n
p
1

+1M
n
p
2

+8M
n
p
3

+2G
n
e


n

+1G
n


t
6
c
w
EOF

mkfs -t ext3 "$DEV_EMMC"p3
mkfs -t ext3 "$DEV_EMMC"p5
/tmp/sd/busybox mkfs.vfat "$DEV_EMMC"p6
