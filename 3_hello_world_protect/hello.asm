%include "boot.inc"

org 0x900
jmp enter

; https://wiki.osdev.org/GDT_Tutorial
; 定义GDT的数据结构
; GDT一个8字节的容器，可以理解为一个int64的数组，每一个item存储一个int64
; 定义第一个描述符GDT信息，分别为两个int32，组成一个int64，第一个数据不会被使用，通常填充0
GDT_BASE: dd 0x00000000
          dd 0x00000000

; 第二个通常为内核代码段
; Base = 0
; Limit = 0xFFFFF
; Access Byte = 0x9A
; Flags = 0xC
KERNEL_CODE_BASE: dd 0x0000FFFFF
                  dd GDT_CODE

; 第三为内核数据段
; Base = 0
; Limit = 0xFFFFF
; Access Byte = 0x92
; Flags = 0xC
KERNEL_DATA_BASE: dd 0x0000FFFFF
                  dd GDT_DATA

; 获取总长度，即Offset
GDT_LENGTH equ $ - GDT_BASE ; 当前地址 - 起始地址

; 构建GDT的48位结构，长度 & 起始地址
GTD_PRT dw GDT_LENGTH ; 总长度
        dd GDT_BASE ; 起始地址

enter:
    ; 打开A20地址线，
    in al, 0x92
    or al, 00000010B
    out 0x92, al

    ; 载入到GTDR寄存器中
    lgdt [GTD_PRT]

    ; 当GDT载入到GDTR寄存器后，还需要打开cpu的保护模式，这样cpu才算切换完成。
    ; x86 cpu是通过设置CR0寄存器的PE位为1来进入保护模式。PE（Protection Enable）位在CR0的第1位（位0）。
    ; 打包保护模式
    mov eax, cr0    ; 读取cr0寄存器的信息
    or  eax, 0x00000001      ; 把第0位置为1
    mov cr0, eax    ; 回写到CR0寄存器
