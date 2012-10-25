#!/bin/sh
export UPDATE_DIR=/tmp/sd/
cd $UPDATE_DIR
#./install2.sh 1>$UPDATE_DIR/install.out 2>&1
dmesg > $UPDATE_DIR/dmesg.out

