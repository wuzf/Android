#!/bin/bash
./mkbootfs ./ramdisk | gzip > ramdisk-new.gz
#GB的ramdiskaddr好像是0x41300000，ICS的ramdiskaddr好像是0x41A00000，若设置错误不知道会怎样，没试过
./mkbootimg --kernel $1-kernel --ramdisk ramdisk-new.gz --cmdline "vmalloc=450M,console=ttyDCC0,115200,n8 androidboot.hardware=qcom" --base 0x40200000 --pagesize 2048 --ramdiskaddr 0x41A00000 -o new$1

