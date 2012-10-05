#!/system/bin/sh

# EMMC partitions - new
#p1:   1M  u-boot-emmc
#p2:   8M  uImage-recovery
#p3:   8M  uImage
#p4:  ---  extented partition
#p5:   2G  android /
#p6:   1G  android data
#p7: ----  user data

DEV_EMMC=/dev/mmcblk0

busybox fdisk "$DEV_EMMC" <<EOF
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

+1M
n
p
2

+8M
n
p
3

+8M
n
e


n

+2G
n

+1G
n


t
7
c
w
EOF

busybox mkfs.vfat "$DEV_EMMC"p8
