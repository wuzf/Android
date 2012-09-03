#!/bin/bash

BOOTIMG=$1

dd if=$BOOTIMG ibs=1 skip=64 > Image.lzma

lzma -cd Image.lzma > Image

INICIO=$( grep -P -a -b -m 1 --only-matching $'\x42\x5a\x68\x39' Image | cut -d: -f1 )

dd if=Image bs=1 skip=167936 > initramfs.cpio.bz2+garbage
bzip2 -cd initramfs.cpio.bz2+garbage > initramfs.cpio
bzip2 -c initramfs.cpio > initramfs.cpio.bz2

TAM=$( wc -c < initramfs.cpio.bz2 )

rm initramfs.cpio.bz2+garbage

# Save the part before the initramfs for repack
dd if=Image of=Image.HEAD bs=1 count=$INICIO

# Save the part after the initramfs for repack
dd if=Image of=Image.FOOT bs=1 skip=$(( INICIO + TAM ))

#cat Image.HEAD initramfs.cpio.bz2 Image.FOOT | md5sum
#md5sum Image

[ -d initramfs ] && rm -r initramfs
mkdir initramfs
cd initramfs
cpio -i --no-absolute-filenames < ../initramfs.cpio
cd -
