# Preparing bootloader files SD for EMEV firmware update
UBOOT=..
DEST=$1

echo "making SD-boot loaders ... "
cd $UBOOT
make distclean
make emev_sd_line_config
make
cp ./sdboot.bin $DEST/sdboot.bin
cp ./uboot-sd.bin $DEST/uboot-sd.bin
echo "making EMMC-boot loader ... "
make distclean
make emev_emmc_config
make
if [[ $? -ne 0 ]]
then
    echo "compilation failed"
    exit -1
fi
cp ./u-boot-emmc.bin $DEST/uboot4.bin
echo "moving companion files ... "
cp -r ./fwupd/* $DEST

