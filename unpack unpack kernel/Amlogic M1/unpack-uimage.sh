#!/bin/sh

#
# Copyright (C) 2010 Matthias Buecher (http://www.maddes.net/)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# http://www.gnu.org/licenses/gpl-2.0.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#

UIMAGE=$1

# check for uImage magic word
# http://git.denx.de/cgi-bin/gitweb.cgi?p=u-boot.git;a=blob;f=include/image.h
echo 'Checking for uImage magic word...'
MAGIC=`dd if="${UIMAGE}" ibs=4 count=1 | hexdump -v -e '1/1 "%02X"'`
[ '27051956' != "${MAGIC}" ]  && { echo 'Not a uImage.' ; exit 1 ; }

# extract data from uImage
echo 'uImage recognized.'
echo 'Extracting data...'
DATAFILE='uImage.data'
dd if="${UIMAGE}" of="${DATAFILE}" ibs=64 skip=1

# check for ARM mach type ( xx 1C A0 E3 xx 10 81 E3 )
# http://www.simtec.co.uk/products/SWLINUX/files/booting_article.html#d0e600
echo 'Checking for ARM mach-type...'
MAGIC=`dd if="${DATAFILE}" ibs=1 skip=1 count=3 | hexdump -v -e '1/1 "%02X"'`
[ '1CA0E3' = "${MAGIC}" ] && {
	MAGIC=`dd if="${DATAFILE}" ibs=1 skip=5 count=3 | hexdump -v -e '1/1 "%02X"'`
	[ '1081E3' = "${MAGIC}" ] && {
		echo 'ARM mach-type header recognized.'
		echo 'Extracting mach-type header...'
		dd if="${DATAFILE}" of="uImage.mach-type" ibs=8 count=1
                ARCH=$(hexdump -v -e '1/1 "%02X "' uImage.mach-type); echo "The mach-type is: $ARCH"
		echo 'Stripping mach-type header...'
		TMPFILE='uImage.tmp'
		dd if="${DATAFILE}" of="${TMPFILE}" ibs=8 skip=1
		rm -f "${DATAFILE}"
		mv "${TMPFILE}" "${DATAFILE}"
	}
}

TMPFILE='Image'
echo 'Checking for zImage...'
MAGIC=`dd if="${DATAFILE}" ibs=4 skip=9 count=1 | hexdump -v -e '1/1 "%02X"'`
[ '18286F01' = "${MAGIC}" ] && {
	START=`dd if="${DATAFILE}" ibs=4 skip=10 count=1 | hexdump -v -e '1/4 "%08X"'`
	END=`dd if="${DATAFILE}" ibs=4 skip=11 count=1 | hexdump -v -e '1/4 "%08X"'`
#
	SIZE=$(( 0x${END} - 0x${START} ))
#
	echo "zImage recognized with start 0x${START}, end 0x${END} and size ${SIZE}."
	TMPFILE='zImage'
}
mv "${DATAFILE}" "${TMPFILE}" 

echo ">>> ${UIMAGE} extracted to ${TMPFILE}"

inputfile=${TMPFILE}-ext

unlzma < ${TMPFILE} > $inputfile
echo ">>> ${TMPFILE} unlzma'd to $inputfile"

start=`grep -a -b -m 1 --only-matching '070701' $inputfile | head -1 | cut -f 1 -d :`
end=`grep -a -b -m 1 --only-matching 'TRAILER!!!' $inputfile | head -1 | cut -f 1 -d :`


if [ ! -z $start ] || [ ! -z $end ]; then
        #11 bytes = length of TRAILER!!! zero terminated string, fixes premature end of file warning in CPIO
        end=$((end + 14))
        [ -z $DEBUG ] || echo "-D- Kernel start = $start"
        [ -z $DEBUG ] || echo "-D- Kernel end = $end"
        count=$((end - start))

            if (($count < 0)); then
		echo "-E- Couldn't match start/end of the initramfs image."
                exit 1
            fi

	echo "Extracting initramfs image (start = $start, end = $end)"
	dd if=$inputfile of=initramfs.cpio bs=1 skip=$start count=$count
else
	echo "-E- No CPIO image found in $inputfile."
fi

rm -rf initramfs
mkdir initramfs
cd initramfs
cpio -i --no-absolute-filenames < ../initramfs.cpio
echo "initramfs.cpio extracted"
cd ..
chmod -R 777 initramfs



