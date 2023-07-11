#!/bin/bash
# create empty disk
bximage -func=create -hd=10M -q boot.img
echo "Create image done."

# build img
nasm -f bin boot.asm -o .temp_bin.bin
nasm -f bin hello.asm -o .temp_hello.bin
nasm -f elf -o print.o print.asm
nasm -f elf -o idt_asm.o idt.asm
i386-elf-gcc -I ./ -c -fno-builtin -o idt.o idt.c
i386-elf-gcc -I ./ -c -o main.o main.c
i386-elf-ld -Ttext 0xc0001500 -e main -o .temp_kernel.bin main.o print.o idt_asm.o idt.o

# write to disk
dd if=.temp_bin.bin of=boot.img bs=512 count=1 conv=notrunc
dd if=.temp_hello.bin of=boot.img bs=512 count=4 seek=2 conv=notrunc
dd if=.temp_kernel.bin of=boot.img bs=512 count=200 seek=9 conv=notrunc

rm -rf .temp_bin.bin
rm -rf .temp_hello.bin
rm -rf .temp_kernel.bin
rm -rf main.o
rm -rf print.o
rm -rf idt.o
rm -rf idt_asm.o
exit