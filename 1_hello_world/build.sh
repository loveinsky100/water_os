#!/bin/bash
if [[ -n "$1" ]]; then
	# create empty disk
	bximage -func=create -hd=10M -q boot.img
	echo "Create image done."

	# build img
	nasm -f bin $1 -o .temp_bin.bin
	# write to disk
	dd if=.temp_bin.bin of=boot.img bs=512 count=1 conv=notrunc
	rm -rf .temp_bin.bin

	exit
fi

echo "please input file"
