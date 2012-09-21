# Preparing bootloader files SD for EMEV firmware update
UBOOTSRC=/media/u02/RenesasEV2/bootloader/u-boot
DEST=$AOSP/device/renesas/emev/pack/

cd $UBOOTSRC
echo "making SD-boot loaders ... "
make distclean
make emev_sd_line_config
make
cp ./sdboot.bin $DEST/sdboot.bin
cp ./uboot-sd.bin $DEST/uboot-sd.bin
echo "making EMMC-boot loader ... "
make distclean
make emev_emmc_config
make
cp ./u-boot-emmc.bin $DEST/uboot4.bin
echo "moving companion files ... "
cp -r ./fwupd/* $DEST

