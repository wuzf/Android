#!/bin/bash
RMDDISK_DIR=./ramdisk
if [ -d $RMDDISK_DIR ]; then
	rm -fr $RMDDISK_DIR
fi
	mkdir -p $RMDDISK_DIR
./split_bootimg.pl $1
cd $RMDDISK_DIR
gzip -dc ../$1-ramdisk.gz | cpio -i

