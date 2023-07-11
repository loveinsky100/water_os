#!/bin/bash
# create empty disk
bximage -func=create -hd=10M -q boot.img
echo "Create image done."

# build img
nasm -f bin boot.asm -o .temp_bin.bin
nasm -f bin hello.asm -o .temp_hello.bin
# write to disk
dd if=.temp_bin.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=.temp_hello.bin of=boot.img bs=512 count=4 seek=2 conv=notrunc
rm -rf .temp_bin.bin
rm -rf .temp_hello.bin

exit