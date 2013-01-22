#!/bin/bash

# we need out/host/linux-x86/bin/mkbootfs in the path
mkbootfs initramfs > initramfs.new.cpio

bzip2 -1 < initramfs.new.cpio > initramfs.new.cpio.bz2

OLDSIZE=$( wc -c < initramfs.cpio.bz2 )
NEWSIZE=$( wc -c < initramfs.new.cpio.bz2 )

if [ $NEWSIZE -gt $OLDSIZE ]; then
        echo "New initramfs is too big ($NEWSIZE vs $OLDSIZE)"
        #exit 1
else
        FREESIZE=$((OLDSIZE - $NEWSIZE))
        echo "New initramfs is $NEWSIZE bytes ($FREESIZE bytes spare)"

fi

echo "Adding padding to end of initramfs.new.cpio"
cp initramfs.new.cpio.bz2 initramfs.new.cpio.bz2.pad
dd if=/dev/zero bs=1 count=$FREESIZE >> initramfs.new.cpio.bz2.pad

cat Image.HEAD initramfs.new.cpio.bz2.pad Image.FOOT > Image.new

echo "Compressing kernel to LZMA"
lzma < Image.new > Image.new.lzma

# https://dl.dropbox.com/u/788286/superteam/mkimage_amlogic
echo "Making uImage"
mkimage_amlogic -A arm -O linux -T kernel -C lzma -a 80008000 -e 80008000 -d Image.new.lzma -n uImage_recovery uImage.new