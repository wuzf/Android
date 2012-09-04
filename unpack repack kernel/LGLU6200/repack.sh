#!/bin/bash
./mkbootfs ./ramdisk | gzip > ramdisk-new.gz
./mkbootimg --kernel boot.img-kernel --ramdisk ramdisk-new.gz --cmdline "vmalloc=450M, console=ttyDCC0,115200,n8 androidboot.hardware=qcom" --base 0x40200000 --pagesize 2048 --ramdiskaddr 0x41300000 -o newboot.img

